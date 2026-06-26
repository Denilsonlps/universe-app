import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Registra o dispositivo no FCM e guarda o token em users/{uid}.
/// No web é ignorado (push web exige VAPID + service worker — ver push-fcm-setup.md).
class PushService {
  PushService(this._db);
  final FirebaseFirestore _db;
  final _fm = FirebaseMessaging.instance;
  String? _uid;

  Future<void> registerFor(String uid) async {
    if (kIsWeb) return;
    if (_uid == uid) return;
    try {
      final settings = await _fm.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await _fm.getToken();
      debugPrint('PushService: permissão=${settings.authorizationStatus}, token=${token == null ? "null" : "ok"}');
      if (token != null) await _save(uid, token);
      _uid = uid;
      _fm.onTokenRefresh.listen((t) => _save(uid, t));
    } catch (e) {
      debugPrint('PushService: falha ao registrar token: $e');
    }
  }

  Future<void> _save(String uid, String token) => _db.collection('users').doc(uid).set(
        {'fcmTokens': FieldValue.arrayUnion([token])}, SetOptions(merge: true));

  void clear() => _uid = null;
}
