from news import casa_keyword, news_doc_id

def test_casa_keyword():
    assert casa_keyword("Inscrições do Sisu começam hoje")
    assert casa_keyword("Concurso público abre vagas")
    assert casa_keyword("IFSP divulga edital")
    assert not casa_keyword("Receita de bolo de cenoura")

def test_news_doc_id():
    a = news_doc_id("https://x/1")
    assert a == news_doc_id("https://x/1") and len(a) == 40
