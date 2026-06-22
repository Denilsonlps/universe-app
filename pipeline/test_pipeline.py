from main import map_course, vaga_id

def test_map_course():
    assert map_course("Tecnologia em Análise e Desenvolvimento de Sistemas") == "ADS"
    assert map_course("Técnico em Redes de Computadores") == "Redes"
    assert map_course("Bacharelado em Engenharia de Produção") == "Eng. de Produção"
    assert map_course("") == "Todos"
    assert map_course("Curso inexistente") == "Todos"

def test_vaga_id_estavel():
    a = vaga_id("https://x/1")
    b = vaga_id("https://x/1")
    assert a == b and len(a) == 40
