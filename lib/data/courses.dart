/// Cursos oferecidos pelo campus (rótulos curtos usados em filtros e no perfil).
/// Fonte: design_reference/project/universe/data.jsx (DATA.estagioCourses/courses).
const campusCourses = <String>[
  'Análise e Desenvolvimento de Sistemas',
  'Gestão Pública',
  'Letras — Português / Inglês',
  'Engenharia de Produção',
  'Administração',
  'Redes de Computadores',
  'Logística',
  'PROEJA — Administração',
  'Gestão de Projetos',
  'Humanidades',
];

/// Rótulo curto do curso usado nos filtros de estágio (ex.: 'ADS').
const courseShortLabels = <String>[
  'Todos', 'ADS', 'Gestão Pública', 'Eng. de Produção', 'Redes', 'Administração', 'Logística',
];

/// Mapeia o nome completo do curso para o rótulo curto de filtro de estágios.
String courseShort(String fullName) => switch (fullName) {
      'Análise e Desenvolvimento de Sistemas' => 'ADS',
      'Gestão Pública' => 'Gestão Pública',
      'Engenharia de Produção' => 'Eng. de Produção',
      'Redes de Computadores' => 'Redes',
      'Administração' => 'Administração',
      'Logística' => 'Logística',
      _ => 'Todos',
    };
