# SP5 — Pipeline de Notícias automatizado (RSS + Gemini → aprovação no app) · Documento de Design

**Data:** 2026-06-23
**Fase:** SP5 — Camada externa (pipeline de notícias) + curadoria no app
**Projeto:** Universe — app do IFSP Campus Pirituba

> Espelha a arquitetura do SP4 (vagas), agora para **notícias**: um pipeline coleta de
> fontes de referência (RSS), o Gemini filtra relevância + categoriza + resume, e o
> resultado vira **sugestões** que o Setor aprova no app. Brainstorming aprovado em
> 2026-06-23. Reaproveita o modelo `News` (SP3c).

## 1. Objetivo

Alimentar a aba de Notícias automaticamente, sem digitação: o pipeline lê fontes
oficiais/educacionais, descarta o irrelevante via IA, gera um **resumo curto próprio**
e grava **sugestões**; no app, o Setor aprova/edita/recusa, e só então a notícia
aparece para o aluno (RF037). Por direitos autorais, guarda-se apenas **título +
resumo gerado + link para a matéria completa** na fonte.

## 2. Contrato — coleção `noticias_sugeridas`

Doc `noticias_sugeridas/{id}` (**id = `sha1(link)`**, idempotente):
- Campos do modelo `News` (já existe): `category, source, readTime, title, summary,
  body, date (epoch-ms), facts (lista de {label,value}), sourceUrl, imageUrl,
  published, pinned`.
- Metadados de staging: `scrapedAt` (epoch-ms), `status: 'pendente' | 'recusada'`.
- Convenções de conteúdo:
  - `summary` e `body` = **resumo gerado pelo Gemini** (2-3 frases; `body` pode repetir
    o resumo — não armazenar texto integral da fonte).
  - `sourceUrl` = link da matéria; `source` = veículo (ex.: "G1", "MEC", "IFSP").
  - `date` = data de publicação do feed; `readTime` = "1 min"; `facts` = `[]`;
    `imageUrl` = imagem do feed quando houver (senão null); `pinned` = false.

## 3. Pipeline Python (`pipeline/news.py`)

Vive em `pipeline/`. Reaproveita `init_firestore()` e `init_gemini()` de `main.py`
(import). Nova dependência: **`feedparser`** (RSS).

**Configuração de fontes** (`FEEDS`, lista de dicts): cada uma com `source` (rótulo) e
`url` (RSS). Conjunto inicial:
- **G1 Educação:** `https://g1.globo.com/rss/g1/educacao/`
- **gov.br / MEC / Inep:** feed(s) oficiais de notícias do MEC/Inep (Enem/SiSU). Onde
  não houver RSS estável, a fonte fica documentada e o pré-filtro/keywords garante
  relevância.
- **Concursos:** um feed de concursos (ex.: PCI Concursos) quando disponível.
- **IFSP:** RSS do portal se existir; **senão**, um scrape leve da página de notícias
  (`requests` + parse simples). Se o IFSP se mostrar frágil, fica como ajuste posterior
  (começa com G1/gov/concursos) — decisão registrada no plano.

**Palavras-chave** (`KEYWORDS`): `ifsp, sisu, enem, prouni, fies, concurso, edital,
estágio, bolsa, vestibular, matrícula`. Pré-filtro no título+resumo do feed (case-
insensitive, sem acento) antes de chamar o Gemini (economiza cota).

**Fluxo por execução:**
1. Para cada feed: baixa entradas (`feedparser`), pega `title, link, summary, published,
   media/imagem`.
2. `id = sha1(link)`. Pula se já existe `news/{id}` (aprovada) ou
   `noticias_sugeridas/{id}.status == 'recusada'`.
3. Pré-filtro por palavra-chave; se não casar, descarta.
4. **Gemini (JSON):** recebe título+resumo do feed e devolve
   `{ relevante: bool, category: 'Campus'|'SiSU'|'Enem'|'Concurso'|'Geral',
   summary: string (2-3 frases) }`. Se `relevante == false`, descarta.
5. Monta o doc (campos `News` + `scrapedAt`, `status:'pendente'`) e grava em
   `noticias_sugeridas/{id}` com `set` (sem merge — `ja_tratada` já barra
   aprovadas/recusadas).
6. Respeita um teto `MAX_NOTICIAS` (env, padrão 15) somando todas as fontes.

**Robustez:** try/except por entrada e por feed (uma fonte fora do ar não derruba o
lote); retry do Gemini igual ao de vagas (rate-limit + 503).

**Agendamento:** `.github/workflows/pipeline-noticias.yml` (cron diário, ex.: 06:30
UTC; + `workflow_dispatch`), só HTTP/RSS → roda no runner do GitHub. Reusa os secrets
`FIREBASE_SERVICE_ACCOUNT` e `GEMINI_API_KEY`.

**Testes (Python):** `casa_keyword(texto)`; `news_doc_id(link)` (sha1 estável);
parsing tolerante do JSON do Gemini.

## 4. App — curadoria

### 4.1 Modelo `NoticiaSugerida`
`NoticiaSugerida { id, News noticia, DateTime scrapedAt, String status }`.
`fromMap(id, m)` reusa `News.fromMap(id, m)` + lê `scrapedAt`/`status`. `toMap()` =
`{...noticia.toMap(), scrapedAt, status}`.

### 4.2 Repositório + provider
- `Stream<List<NoticiaSugerida>> watchNoticiasSugeridas()` — `status=='pendente'`,
  ordenado por `scrapedAt` desc.
- `Future<void> rejeitarNoticiaSugerida(String id)` (set status 'recusada', merge).
- `Future<void> deleteNoticiaSugerida(String id)`.
- Aprovar reusa `upsertNews(noticia)` (mesmo id) + `deleteNoticiaSugerida(id)`.
- Firestore + Fake (2 exemplos). Provider `noticiasSugeridasProvider`.

### 4.3 Telas (admin)
- **Hub:** card **"Notícias sugeridas"** com contagem de pendentes →
  `/admin/noticias-sugeridas`.
- **`AdminNoticiasSugeridasScreen`:** lista (`AsyncListView`), cada card com categoria,
  fonte, título + resumo e ações **Aprovar / Editar / Recusar**.
  - Aprovar: `upsertNews` + `deleteNoticiaSugerida`.
  - Editar: abre `AdminNewsEditScreen` pré-preenchido com a `News` e
    `fromSuggestionId`; ao salvar, remove a sugestão.
  - Recusar: confirmação → `rejeitarNoticiaSugerida`.
- **`AdminNewsEditScreen`** ganha parâmetro opcional `fromSuggestionId` (no salvar,
  remove a sugestão de origem) — igual ao `VagaFormScreen`.

## 5. Segurança + regras

- **Firestore:** `noticias_sugeridas` é **só admin**. Estende o catch-all de leitura
  (mesmo padrão de `news`/`vagas_sugeridas`):
  ```
  allow read: if signedIn()
    && (col != 'vagas_sugeridas' || isAdmin())
    && (col != 'noticias_sugeridas' || isAdmin())
    && (col != 'news' || isAdmin() || resource.data.published == true);
  ```
- Service account só no pipeline (secret). O pipeline (admin SDK) ignora as regras.

## 6. Reuso + testes (app)

Reusa `News`, `AdminNewsEditScreen`, `AsyncListView`, `AppCard`/`AppButton`/`IconTile`,
`GreenHero`/`PageShell`, e o padrão de staging/curadoria do SP4. Testes:
- Round-trip `NoticiaSugerida`; `watchNoticiasSugeridas` só pendentes (ordem desc);
  aprovar cria `News` + remove sugestão; recusar marca recusada; smoke da tela.
- Fake popula 2 notícias sugeridas de exemplo (dev/seed).

## 7. Escopo

**Inclui:**
- **App:** modelo `NoticiaSugerida`; repo (watch/rejeitar/delete) + provider + contagem;
  `AdminNoticiasSugeridasScreen` + card no hub; `AdminNewsEditScreen.fromSuggestionId`;
  regra Firestore; testes; exemplos no Fake/seed.
- **Pipeline:** `pipeline/news.py` (RSS + keyword + Gemini relevância/categoria/resumo +
  firebase-admin + dedup), `feedparser` no `requirements.txt`,
  `.github/workflows/pipeline-noticias.yml`, doc no `pipeline/README.md`.

**Fora:** texto integral; push notifications; relevância avançada/ML; gestão de fontes
por UI (lista fixa no código); tradução.

## 8. Divisão de implementação

- **App-side:** neste repo, subagent-driven.
- **Pipeline-side:** `news.py` + workflow versionados; **o usuário** já tem os secrets
  (reaproveitados) e só precisa deixar o Actions habilitado. Ajustar feeds que mudarem
  é manutenção esperada.

## 9. Riscos / notas

1. **Feeds variam:** alguns podem mudar/cair; try/except por feed + o filtro do Gemini
   evitam quebra e ruído. IFSP pode não ter RSS → fallback de scrape leve ou adiar.
2. **Direitos autorais:** só título + resumo próprio + link (sem texto integral).
3. **Regra de leitura** estendida no catch-all (não criar match separado — união
   reabriria), como `news`/`vagas_sugeridas`.
4. **Cota do Gemini:** pré-filtro por palavra-chave reduz chamadas; `MAX_NOTICIAS`
   limita o volume.
5. **`News.body`** recebe o resumo (não o texto integral) — a tela de detalhe mostra o
   resumo + o card "Fonte oficial" com o link, que já existe no SP3c.
6. **Operacional do usuário:** publicar a regra do Firestore atualizada; manter o
   Actions habilitado; re-rodar seed (exemplos).
