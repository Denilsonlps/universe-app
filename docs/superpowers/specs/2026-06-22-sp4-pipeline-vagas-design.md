# SP4 — Pipeline de Vagas Automatizado (scraping + Gemini → aprovação no app) · Documento de Design

**Data:** 2026-06-22
**Fase:** SP4 — Camada externa (pipeline de dados) + curadoria no app
**Projeto:** Universe — app do IFSP Campus Pirituba

> Implementa a **camada de processamento externo** da arquitetura de 3 camadas do
> TCC (seção 2.4.1): script Python faz web scraping de vagas, o Gemini categoriza e
> **enriquece**, e o resultado vira **sugestões** que o Setor de Estágios aprova no
> app. Evolui a arquitetura documentada (de "CSV + cadastro manual" para "pipeline →
> Firestore + aprovação no app"). Brainstorming aprovado em 2026-06-22.

## 1. Objetivo

Reduzir o trabalho manual do Setor de Estágios: o pipeline coleta vagas (Gupy),
enriquece com IA (descrição, requisitos, benefícios, bolsa, curso) e grava
**sugestões** numa coleção de staging; no app, o Setor **aprova / edita / recusa** —
e só então a vaga aparece para o aluno (RF037: o app só divulga). Mantém o humano
como curador, mas elimina a re-digitação.

## 2. Contrato compartilhado — coleção `vagas_sugeridas`

Elo entre pipeline (escreve) e app (lê/cura). Documento `vagas_sugeridas/{id}`:
- **`id = sha1(link)`** (hex) — idempotente: re-execuções atualizam o mesmo doc.
- Campos do payload (espelham `Internship`): `role, companyName, area, duration,
  jobDescription, requirements: [String], niceToHave: [String], companyDescription,
  benefits: [String], grant, course (rótulo curto do app), mode, link`.
- Metadados: `source: 'gupy-auto'`, `scrapedAt` (epoch-ms int), `status: 'pendente' |
  'recusada'`.
- Listas como arrays de String (sem aninhamento). Datas epoch-ms.

## 3. Pipeline Python (parte B — fora do app, versionado em `pipeline/`)

Evolui o `main.py` atual. Vive em `pipeline/` neste repositório (mono-repo: facilita
GitHub Actions + serve de evidência ao TCC).

**Fluxo por execução:**
1. Inicializa `firebase-admin` com uma **service account** (credencial de servidor —
   ignora as regras de segurança). Caminho/JSON via variável de ambiente.
2. Scraping da listagem (Gupy, termo "estágio"), como hoje (Selenium headless),
   coletando ao menos o **link** de cada vaga.
3. Para cada vaga: `id = sha1(link)`. **Pula** se:
   - já existe `internships/{id}` (vaga já aprovada), ou
   - `vagas_sugeridas/{id}.status == 'recusada'` (já descartada pelo Setor).
4. **Enriquecimento:** navega na **página da vaga**, extrai o texto e chama o Gemini
   em **modo JSON** (response schema) para obter:
   `{ course, area, duration, grant, jobDescription, requirements[], niceToHave[],
   benefits[], companyDescription }`. `course` deve ser **um dos rótulos curtos do
   app** (lista no prompt): `ADS, Gestão Pública, Eng. de Produção, Redes,
   Administração, Logística` (ou `Todos` se não identificado). `mode` vem da
   listagem (Presencial/Híbrido/Remoto).
5. Grava `vagas_sugeridas/{id}` via `set(..., merge=true)` com `status:'pendente'`,
   `source:'gupy-auto'`, `scrapedAt=now`. (merge preserva um eventual `recusada`.)
6. CSV opcional mantido (evidência do TCC).

**Agendamento:** workflow **GitHub Actions** (`.github/workflows/pipeline-vagas.yml`)
em cron (ex.: diário 06:00 UTC) — instala Python + Chrome, roda o script com os
secrets `GEMINI_API_KEY` e `FIREBASE_SERVICE_ACCOUNT` (JSON).

**Robustez:** rate-limit do Gemini já tratado no script (retry com backoff);
try/except por vaga para não abortar o lote; `max_vagas` configurável.

**Testes (Python, leves, sem rede):** `map_course(nome_completo) -> rótulo curto`;
parsing tolerante do JSON do Gemini (campos ausentes viram `''`/`[]`).

## 4. App — coleção + curadoria (parte A — implementada neste repo)

### 4.1 Modelo `VagaSugerida`
`VagaSugerida { String id; Internship vaga; DateTime scrapedAt; String source; String status; }`
- `fromMap(id, map)`: lê `Internship.fromMap(id, map)` para o payload + `scrapedAt`,
  `source`, `status` do mesmo mapa. `toMap()`: `{...vaga.toMap(), scrapedAt, source,
  status}`. (Reusa o `Internship` existente; sem duplicar serialização de campos.)

### 4.2 Repositório
- `Stream<List<VagaSugerida>> watchVagasSugeridas()` — `status == 'pendente'`,
  ordenado por `scrapedAt` desc (filtro/sort no cliente, padrão do app).
- `Future<void> rejeitarVagaSugerida(String id)` — `set(status:'recusada', merge)`.
- `Future<void> deleteVagaSugerida(String id)` — remove o doc.
- **Aprovar** reusa `upsertInternship(vaga)` (com o **mesmo id** = sha1(link)) +
  `deleteVagaSugerida(id)`. (Mesmo id garante o dedup do pipeline.)
- Firestore + Fake. Providers: `vagasSugeridasProvider` (StreamProvider) e um
  derivado de contagem para o badge do hub.

### 4.3 Telas (admin)
- **Hub** (`/admin`): 4º card **"Vagas sugeridas"** com contagem de pendentes →
  `/admin/sugestoes`.
- **`AdminSugestoesScreen`** (`/admin/sugestoes`): lista das pendentes
  (`AsyncListView`), cada card com `role`, `companyName`, `course`, `source` e três
  ações:
  - **Aprovar:** `upsertInternship(vaga)` + `deleteVagaSugerida(id)` + aviso.
  - **Editar:** abre `VagaFormScreen` pré-preenchido com `vaga` e `fromSuggestionId:id`;
    ao salvar, cria a vaga e remove a sugestão.
  - **Recusar:** confirmação → `rejeitarVagaSugerida(id)`.
  - Estado vazio: "Nenhuma sugestão pendente".
- **`VagaFormScreen`**: novo parâmetro opcional `fromSuggestionId`; no salvar com
  sucesso, se setado, chama `deleteVagaSugerida(fromSuggestionId)`.

## 5. Segurança + regras

- **Service account** apenas no pipeline (secret do GitHub Actions). **Nunca** no app
  nem no repositório (entra no `.gitignore`). O pipeline (admin SDK) ignora as regras.
- **Firestore:** `vagas_sugeridas` é **só admin** (aluno não lê nem escreve). Estender
  o catch-all de leitura:
  ```
  allow read: if signedIn()
    && (col != 'vagas_sugeridas' || isAdmin())
    && (col != 'news' || isAdmin() || resource.data.published == true);
  allow write: if isAdmin();
  ```
  (A escrita admin do catch-all cobre a aprovação/recusa pelo app.)

## 6. Regras de negócio

- **RF037 (só divulga):** nada chega ao aluno sem aprovação (staging + curadoria).
- **Procedência:** `source: 'gupy-auto'` distingue de vagas manuais; edição do admin
  prevalece (vira `Internship` normal após aprovar).
- **Dedup:** `id = sha1(link)` em todas as pontas; aprovar reusa o id; recusar deixa
  tombstone.

## 7. Testes (app)

- Round-trip `VagaSugerida` (payload `Internship` + metadados).
- `watchVagasSugeridas` retorna só pendentes, ordenadas por `scrapedAt` desc.
- `rejeitarVagaSugerida` marca `recusada` (sai da lista de pendentes).
- Aprovar: `upsertInternship` chamado e sugestão removida (smoke com Fake repo).
- Smoke da `AdminSugestoesScreen` (lista + ação Recusar).
- Fake popula 1–2 sugestões de exemplo (dev).

## 8. Escopo

**Inclui:**
- **App:** modelo `VagaSugerida`; repositório (`watchVagasSugeridas`,
  `rejeitar`, `delete`) + providers + contagem; `AdminSugestoesScreen` + card no hub;
  `VagaFormScreen.fromSuggestionId`; regra Firestore de `vagas_sugeridas`; testes;
  sugestões de exemplo no Fake/seed.
- **Pipeline (`pipeline/`):** `main.py` evoluído (firebase-admin + dedup + fetch da
  página + Gemini estruturado + escrita em `vagas_sugeridas`), `requirements.txt`,
  `.github/workflows/pipeline-vagas.yml`, `pipeline/README.md` (setup: secrets,
  service account, como rodar local e no Actions), `.gitignore` da credencial.

**Fora:**
- Auto-encerramento de vaga que sumiu do scrape (RF034 v2 — futuro).
- Outras fontes além da Gupy; reprocessamento de histórico; painel de métricas do
  pipeline.
- Edição do texto do TCC (o autor faz depois).

## 9. Divisão de implementação

- **App-side:** neste repo, subagent-driven (como as fases anteriores).
- **Pipeline-side:** os arquivos Python + workflow são escritos em `pipeline/`
  (versionados); **o usuário** cria os secrets (service account + GEMINI_API_KEY) e
  ativa o GitHub Actions. A execução real depende desses passos operacionais.

## 10. Riscos / notas

1. **Seletores da Gupy** podem mudar (scraping é frágil) — manter try/except por vaga
   e logs; é esperado manutenção pontual.
2. **Gemini JSON** pode vir malformado — usar response schema + parsing tolerante;
   campos ausentes não quebram o doc.
3. **Service account** é credencial sensível — só em secret; `.gitignore` cobre o JSON.
4. **`fromMap` de `VagaSugerida`** depende de `Internship.fromMap` ignorar chaves
   extras (`scrapedAt`/`source`/`status`) — confirmar (o `fromMap` atual lê só as
   chaves que conhece, então ok).
5. **Regra de leitura** estendida no catch-all (não criar `match /vagas_sugeridas`
   separado — união reabriria a leitura), igual à lição do `news`.
6. **Operacional do usuário:** publicar a regra do Firestore atualizada; criar a
   service account e os secrets; ativar o Actions; re-rodar seed (sugestões de exemplo).
