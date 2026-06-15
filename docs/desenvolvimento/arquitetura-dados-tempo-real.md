# Atualização de dados e sincronização em tempo real

> Documento de apoio ao TCC. Explica como o app Universe mantém seus dados
> atualizados (cursos, IFSP, benefícios, estágios, concursos) e propõe a solução
> de sincronização, alinhada à arquitetura de três camadas do TCC (§2.4.1).

## Problema

Na fase atual de desenvolvimento, o conteúdo está embutido no app
(`MockUniverseRepository`). Alterar qualquer informação exigiria **gerar e
publicar uma nova versão** do aplicativo — inviável para dados sensíveis ao tempo:
editais de bolsas/auxílios, vagas de estágio e concursos, que surgem e expiram
constantemente.

## Solução: camada de dados no Firebase Firestore

O Firestore (camada de dados do TCC) foi escolhido justamente pela
**sincronização em tempo real entre a aplicação e o servidor** (§2.6 do TCC). A
arquitetura do app já isola o acesso a dados atrás da interface
`UniverseRepository`, então a migração do mock para o Firestore troca apenas a
implementação no provider — as telas não mudam.

### Dois padrões de atualização

| Dado | Padrão | Mecanismo |
|---|---|---|
| Vagas de estágio, concursos, editais de benefícios, notificações | **Tempo real (push)** | O app escuta o Firestore via `snapshots()` → `Stream`. Quando um registro muda, a tela atualiza sozinha, **sem republicar o app**. |
| Cursos, informações do IFSP, FAQ | **Sob demanda + cache** | Mudam raramente. Leitura pontual com cache offline do Firestore; atualiza sem republicar, sem necessidade de stream. |

> **Não é necessário "polling" no app.** O Firestore faz *push* (mais eficiente
> que perguntar periodicamente por novidades). A rotina de atualização fica em
> quem **alimenta** os dados, não no cliente.

## Quem alimenta os dados (as três camadas em ação)

1. **Camada de processamento externo (pipeline Python):** roda de forma
   **agendada** (ex.: cron), coleta vagas por web scraping, categoriza por IA e
   **grava no Firestore**. Essa é a "rotina de atualização" — externa ao app.
2. **Setor de Estágios (admin):** cadastra/edita vagas, editais e benefícios pelo
   **painel admin** do app (planejado) ou pelo console do Firebase.
3. **Estudante:** apenas consulta — e recebe as novidades em tempo real.

## Como encaixa no código

- A interface `UniverseRepository` evolui para expor **`Stream`** nos dados
  dinâmicos (vagas, concursos, benefícios, notificações) e **`Future`** nos
  estáticos (cursos, IFSP, FAQ).
- `MockUniverseRepository` devolve streams de valor único (para dev/testes);
  `FirestoreUniverseRepository` devolve os streams ao vivo.
- No Flutter, um `StreamProvider` (Riverpod) reconstrói a tela automaticamente a
  cada mudança. Estados de carregando/erro/vazio são tratados na UI.
- As regras temporais já modeladas continuam válidas: **RF034** (vaga encerrada
  visível por 30 dias) e **RF036** (edital só no período de inscrição), agora com
  timestamps reais vindos do Firestore.

## Segurança (regras do Firestore)

Na fase de dados, definir regras por papel:
- **Aluno:** leitura do conteúdo público; leitura/escrita **apenas do próprio
  perfil** (`users/{uid}`).
- **Admin (Setor de Estágios):** escrita de vagas, concursos e benefícios.
- Editais/benefícios com data de início/fim; o app filtra por período.

## Sequência recomendada

1. Concluir as **telas de conteúdo no mock** (Planos 4B e 4C) — UI demonstrável.
2. **Plano de Dados (Firestore):** modelar coleções, regras de segurança, migrar
   o repositório para streams em tempo real, ligar persistência offline.
3. **Pipeline Python** + **painel admin** completam o ciclo de alimentação.

A interface de repositório já isola tudo, então a migração para tempo real **não
mexe nas telas** — evitando retrabalho.

> **Nota de documentação do TCC:** o texto pode destacar a sincronização em tempo
> real como diferencial (already previsto na justificativa do Firestore) e
> descrever a rotina agendada do pipeline como a fonte de atualização automática.
