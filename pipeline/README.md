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

## Rodar local
```
cd pipeline
python main.py
```

## Agendado (GitHub Actions)
Veja `.github/workflows/pipeline-vagas.yml`. Configure os secrets do repositório:
- `GEMINI_API_KEY`
- `FIREBASE_SERVICE_ACCOUNT` (cole o JSON inteiro da service account)

## Testes
`cd pipeline && pip install pytest && pytest`
