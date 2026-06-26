// Cloud Function — envia push (FCM) quando nasce uma notificação no Firestore.
// SP7b: gatilho onCreate em `notifications/{id}`; filtra destinatários por curso.
// Deploy: requer plano Blaze. `firebase deploy --only functions`.
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

// Espelha data/courses.dart -> courseShort (nome completo => rótulo curto).
const SHORT = {
  "Análise e Desenvolvimento de Sistemas": "ADS",
  "Gestão Pública": "Gestão Pública",
  "Engenharia de Produção": "Eng. de Produção",
  "Redes de Computadores": "Redes",
  "Administração": "Administração",
  "Logística": "Logística",
};
const courseShort = (full) => SHORT[full] || "Todos";

exports.onNotificationCreated = onDocumentCreated("notifications/{id}", async (event) => {
  const n = event.data && event.data.data();
  if (!n) return;
  const target = n.targetCourse || null; // null = para todos
  console.log(`Notificação criada: target=${target} title="${n.title}"`);

  const db = getFirestore();
  const users = await db.collection("users").get();

  // Mapa token -> docId, para limpar tokens inválidos depois.
  const tokenOwner = {};
  let comToken = 0;
  users.forEach((doc) => {
    const u = doc.data();
    const list = u.fcmTokens;
    if (!Array.isArray(list) || list.length === 0) return;
    comToken += 1;
    if (target && courseShort(u.course) !== target) return; // só o curso-alvo
    list.forEach((t) => { tokenOwner[t] = doc.id; });
  });

  const tokens = Object.keys(tokenOwner);
  console.log(`Usuários: ${users.size}, com token: ${comToken}, tokens-alvo: ${tokens.length}`);
  if (tokens.length === 0) { console.log("Nenhum token-alvo — nada enviado."); return; }

  const messaging = getMessaging();
  const base = {
    notification: { title: n.title || "Universe", body: n.body || "" },
    data: { route: n.route || "", type: n.type || "sistema" },
  };

  const invalid = [];
  for (let i = 0; i < tokens.length; i += 500) {
    const batch = tokens.slice(i, i + 500);
    const res = await messaging.sendEachForMulticast({ ...base, tokens: batch });
    res.responses.forEach((r, idx) => {
      if (!r.success) {
        const code = r.error && r.error.code;
        if (code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-registration-token") {
          invalid.push(batch[idx]);
        }
      }
    });
  }

  // Remove tokens mortos dos respectivos usuários.
  const { FieldValue } = require("firebase-admin/firestore");
  await Promise.all(invalid.map((t) =>
    db.collection("users").doc(tokenOwner[t]).set(
      { fcmTokens: FieldValue.arrayRemove(t) }, { merge: true })));
});
