import os, time, json, re, hashlib
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
from google import genai
from google.genai import types
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

load_dotenv()

# Rótulos curtos de curso usados no app (devem casar com o VagaFormScreen).
CURSOS_APP = ["ADS", "Gestão Pública", "Eng. de Produção", "Redes", "Administração", "Logística", "Todos"]

def map_course(valor: str) -> str:
    """Normaliza o curso retornado pelo modelo para um rótulo do app."""
    if not valor:
        return "Todos"
    v = valor.strip().lower()
    tabela = {
        "ads": "ADS", "análise e desenvolvimento": "ADS", "analise e desenvolvimento": "ADS",
        "gestão pública": "Gestão Pública", "gestao publica": "Gestão Pública",
        "produção": "Eng. de Produção", "producao": "Eng. de Produção", "engenharia": "Eng. de Produção",
        "redes": "Redes", "administração": "Administração", "administracao": "Administração",
        "logística": "Logística", "logistica": "Logística",
    }
    for chave, rotulo in tabela.items():
        if chave in v:
            return rotulo
    for rotulo in CURSOS_APP:
        if rotulo.lower() == v:
            return rotulo
    return "Todos"

def vaga_id(link: str) -> str:
    return hashlib.sha1(link.encode("utf-8")).hexdigest()

def init_firestore():
    cred_path = os.getenv("FIREBASE_SERVICE_ACCOUNT", "service-account.json")
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    return firestore.client()

def init_gemini():
    return genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

PROMPT_EXTRACAO = """Você extrai dados de uma vaga de estágio para um app acadêmico.
Cursos do campus (use EXATAMENTE um destes em "course"): {cursos}
Se nenhum servir, use "Todos".

Texto da vaga:
\"\"\"{texto}\"\"\"

Responda em JSON com as chaves:
course (string), area (string), duration (string), grant (string, bolsa/remuneração),
jobDescription (string, 1-3 frases), companyDescription (string, 1-2 frases),
requirements (array de strings), niceToHave (array de strings), benefits (array de strings).
Use "" ou [] quando não houver a informação. Responda só o JSON."""

def extrair_estruturado(client, texto: str) -> dict:
    prompt = PROMPT_EXTRACAO.format(cursos=", ".join(CURSOS_APP), texto=texto[:6000])
    for tentativa in range(3):
        try:
            resp = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
                config=types.GenerateContentConfig(response_mime_type="application/json"),
            )
            data = json.loads(resp.text)
            return {
                "course": map_course(str(data.get("course", ""))),
                "area": str(data.get("area", "")),
                "duration": str(data.get("duration", "")),
                "grant": str(data.get("grant", "")),
                "jobDescription": str(data.get("jobDescription", "")),
                "companyDescription": str(data.get("companyDescription", "")),
                "requirements": [str(x) for x in (data.get("requirements") or [])],
                "niceToHave": [str(x) for x in (data.get("niceToHave") or [])],
                "benefits": [str(x) for x in (data.get("benefits") or [])],
            }
        except Exception as e:
            erro = str(e)
            m = re.search(r"retry in (\d+)", erro)
            if m:
                time.sleep(int(m.group(1)) + 5)
            else:
                print(f"❌ Erro no Gemini: {e}")
                break
    return {"course": "Todos", "area": "", "duration": "", "grant": "",
            "jobDescription": "", "companyDescription": "", "requirements": [], "niceToHave": [], "benefits": []}

def ja_tratada(db, vid: str) -> bool:
    if db.collection("internships").document(vid).get().exists:
        return True
    sug = db.collection("vagas_sugeridas").document(vid).get()
    return sug.exists and sug.to_dict().get("status") == "recusada"

def coletar_listagem(driver, max_vagas: int):
    """Retorna [(titulo, empresa, modalidade, link)] da listagem da Gupy."""
    driver.get("https://portal.gupy.io/job-search/term=estágio")
    time.sleep(3)
    try:
        b = driver.find_element(By.ID, "privacytools-banner-consent")
        b.find_element(By.TAG_NAME, "button").click()
        time.sleep(1)
    except NoSuchElementException:
        pass
    vagas = []
    while len(vagas) < max_vagas:
        try:
            WebDriverWait(driver, 10).until(EC.presence_of_all_elements_located((By.TAG_NAME, "h3")))
        except TimeoutException:
            break
        cards = driver.find_elements(By.CSS_SELECTOR, "div[aria-label^='Empresa']")
        for card in cards:
            if len(vagas) >= max_vagas:
                break
            try:
                pai = card.find_element(By.XPATH, "./parent::*")
                titulo = pai.find_element(By.TAG_NAME, "h3").text
                empresa = card.find_element(By.TAG_NAME, "p").text
                try:
                    spans = pai.find_elements(By.CSS_SELECTOR, "span.sc-23336bc7-1")
                    modalidade = spans[1].text if len(spans) > 1 else "Presencial"
                except Exception:
                    modalidade = "Presencial"
                link = pai.find_element(By.XPATH, "./ancestor::a[1]").get_attribute("href")
                if titulo and link:
                    vagas.append((titulo, empresa, modalidade, link))
            except Exception:
                continue
        try:
            botao = driver.find_element(By.XPATH, "//button[@aria-label='Próxima página']")
            if not botao.is_enabled():
                break
            driver.execute_script("arguments[0].click();", botao)
            time.sleep(2)
        except NoSuchElementException:
            break
    return vagas

def texto_da_vaga(driver, link: str) -> str:
    driver.get(link)
    time.sleep(2)
    try:
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "main")))
        return driver.find_element(By.TAG_NAME, "main").text
    except Exception:
        return driver.find_element(By.TAG_NAME, "body").text

def main():
    db = init_firestore()
    client = init_gemini()
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    driver = webdriver.Chrome(options=options)
    max_vagas = int(os.getenv("MAX_VAGAS", "30"))

    novas = 0
    try:
        listagem = coletar_listagem(driver, max_vagas)
        print(f"🔎 {len(listagem)} vagas na listagem.")
        for titulo, empresa, modalidade, link in listagem:
            vid = vaga_id(link)
            if ja_tratada(db, vid):
                print(f"⏭️  Pulando (já tratada): {titulo}")
                continue
            print(f"🤖 Enriquecendo: {titulo}")
            extra = extrair_estruturado(client, texto_da_vaga(driver, link))
            doc = {
                "role": titulo, "companyName": empresa, "mode": modalidade, "link": link,
                "tag": "Novo", "open": True, "closedAt": None,
                "source": "gupy-auto", "scrapedAt": int(time.time() * 1000), "status": "pendente",
                **extra,
            }
            db.collection("vagas_sugeridas").document(vid).set(doc, merge=True)
            novas += 1
            time.sleep(2)
    finally:
        driver.quit()
    print(f"✅ {novas} sugestões gravadas em 'vagas_sugeridas'.")

if __name__ == "__main__":
    main()
