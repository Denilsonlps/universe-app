from main import map_course, job_doc_id, map_mode

def test_map_course():
    assert map_course("Tecnologia em Análise e Desenvolvimento de Sistemas") == "ADS"
    assert map_course("Técnico em Redes de Computadores") == "Redes"
    assert map_course("Bacharelado em Engenharia de Produção") == "Eng. de Produção"
    assert map_course("") == "Todos"
    assert map_course("Curso inexistente") == "Todos"

def test_job_doc_id():
    assert job_doc_id(11529036) == "gupy-11529036"
    assert job_doc_id("abc") == "gupy-abc"

def test_map_mode():
    assert map_mode("on-site") == "Presencial"
    assert map_mode("remote") == "Remoto"
    assert map_mode("hybrid") == "Híbrido"
    assert map_mode("") == "Presencial"
    assert map_mode(None) == "Presencial"
