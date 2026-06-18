class GlossaryEntry {
  final String? docId;   // abre /conteudo/<docId>
  final String? term;    // título da ficha (default = chave)
  final String? def;     // definição (abre ficha)
  final String? label;   // rótulo alternativo (não usado no link)
  const GlossaryEntry({this.docId, this.term, this.def, this.label});
}

/// Glossário do app. Transcrito de design_reference/.../data-content.jsx (GLOSSARY).
const glossary = <String, GlossaryEntry>{
  'Cadastro Único': GlossaryEntry(docId: 'gov-cadunico'),
  'CadÚnico': GlossaryEntry(docId: 'gov-cadunico', label: 'Cadastro Único'),
  'ID Jovem': GlossaryEntry(docId: 'gov-idjovem'),
  'Isenções': GlossaryEntry(docId: 'gov-isencoes'),
  'Transporte': GlossaryEntry(docId: 'gov-transporte'),
  'Bilhete Único': GlossaryEntry(docId: 'gov-transporte', label: 'Bilhete Único'),
  'PAP': GlossaryEntry(docId: 'inst-pap'),
  'Monitoria': GlossaryEntry(docId: 'inst-monitoria'),
  'Iniciação Científica': GlossaryEntry(docId: 'inst-ic'),
  'Extensão': GlossaryEntry(docId: 'inst-extensao'),
  'PIBIC': GlossaryEntry(docId: 'inst-ic', term: 'PIBIC', def: 'Programa Institucional de Bolsas de Iniciação Científica. Financia estudantes que desenvolvem pesquisa orientada por um docente, com bolsa mensal do CNPq ou da própria instituição.'),
  'PIBITI': GlossaryEntry(docId: 'inst-ic', term: 'PIBITI', def: 'Programa Institucional de Bolsas de Iniciação em Desenvolvimento Tecnológico e Inovação. Como o PIBIC, mas voltado a projetos de inovação e desenvolvimento tecnológico.'),
  'CRAS': GlossaryEntry(term: 'CRAS', def: 'Centro de Referência de Assistência Social. Unidade pública e gratuita onde você faz e atualiza o Cadastro Único e tem acesso a programas de assistência social. Procure o CRAS mais próximo da sua casa.'),
  'NIS': GlossaryEntry(term: 'NIS', def: 'Número de Identificação Social. Código gerado quando você entra no Cadastro Único; é ele que identifica você nos programas sociais e em pedidos de isenção de taxas.'),
  'SiSU': GlossaryEntry(term: 'SiSU', def: 'Sistema de Seleção Unificada. Plataforma do MEC que usa a nota do Enem para distribuir vagas em universidades e institutos públicos.'),
  'Sisu+': GlossaryEntry(term: 'Sisu+', def: 'Etapa complementar do SiSU criada em 2026 para preencher vagas remanescentes nas instituições públicas, com ingresso no 2º semestre.'),
  'Enem': GlossaryEntry(term: 'Enem', def: 'Exame Nacional do Ensino Médio. A nota do Enem é usada como critério de ingresso em boa parte das vagas das graduações, inclusive no IFSP via SiSU.'),
  'NAPNE': GlossaryEntry(term: 'NAPNE', def: 'Núcleo de Atendimento às Pessoas com Necessidades Específicas. Setor do campus que apoia estudantes com deficiência, garantindo acessibilidade e adaptações.'),
};
