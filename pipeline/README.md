# Pipeline de Vagas — Universe

Coleta vagas de estágio (Gupy), enriquece com o Gemini e grava **sugestões** na
coleção `vagas_sugeridas` do Firestore, para o Setor de Estágios aprovar no app.

## Pré-requisitos
- Python 3.11+, Google Chrome instalado.
- `pip install -r requirements.txt`

## Credenciais (nunca versionar)
1. **Service account:** Firebase Console → Configurações do projeto → Contas de
   serviço → "Gerar nova chave privada". Salve como `pipeline/service-account.json`
   (já no `.gitignore`).
2. **Gemini:** crie uma API key e exporte `GEMINI_API_KEY`.
3. Variáveis (ou um `pipeline/.env`):
   - `GEMINI_API_KEY=...`
   - `FIREBASE_SERVICE_ACCOUNT=service-account.json`
   - `MAX_VAGAS=30` (opcional)

## Rodar local (recomendado)
```
cd pipeline
python main.py
```
No **PowerShell** (Windows), defina as variáveis na sessão antes:
```powershell
$env:GEMINI_API_KEY = "SUA_CHAVE"
$env:FIREBASE_SERVICE_ACCOUNT = "service-account.json"
$env:MAX_VAGAS = "30"
python main.py
```
> Se `python` não for reconhecido no PowerShell, o Python existe mas não está no PATH.
> Reinstale marcando **"Add python.exe to PATH"** (python.org), ou use o caminho completo
> (ex.: `& "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe" main.py`).
> O script já força saída em UTF-8, então emojis no log não quebram o console do Windows.

## Agendar localmente (Agendador de Tarefas do Windows)
Como a Gupy bloqueia IPs de nuvem, agende numa máquina do campus:
1. Crie `pipeline\run.bat` com:
   ```bat
   cd /d D:\projetos\universe_app\pipeline
   set GEMINI_API_KEY=SUA_CHAVE
   set FIREBASE_SERVICE_ACCOUNT=service-account.json
   set MAX_VAGAS=30
   python main.py >> run.log 2>&1
   ```
2. **Agendador de Tarefas** → Criar Tarefa Básica → diária → Ação: "Iniciar um programa" → o `run.bat`.

## GitHub Actions
`.github/workflows/pipeline-vagas.yml` (vagas) e `pipeline-noticias.yml` (notícias)
rodam no runner do GitHub com cron diário + execução manual. Ambos usam a **API JSON**
(Gupy) / **RSS** (notícias) — sem navegador, então passam no runner. Secrets
necessários: `GEMINI_API_KEY` e `FIREBASE_SERVICE_ACCOUNT`.

> Histórico: a 1ª versão de vagas usava Selenium e era bloqueada pelo IP de nuvem da
> Gupy; a migração para a API JSON resolveu, e o cron foi reativado.

## Testes
`cd pipeline && pip install pytest && pytest`

## Pipeline de Notícias (news.py)
Coleta notícias de fontes RSS (G1 Educação, MEC, concursos, IFSP), filtra por
palavra-chave, usa o Gemini para relevância/categoria/resumo e grava em
`noticias_sugeridas` (curadoria no app). Rodar:
```
cd pipeline
python news.py
```
Variáveis: `GEMINI_API_KEY`, `FIREBASE_SERVICE_ACCOUNT`, `MAX_NOTICIAS` (padrão 15).
Agendado em `.github/workflows/pipeline-noticias.yml`. Só título + resumo + link são
guardados (sem texto integral). Feeds que mudarem são manutenção esperada.
