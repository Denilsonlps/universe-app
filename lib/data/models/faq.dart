class Faq {
  final String category, question, answer;
  const Faq({required this.category, required this.question, required this.answer});

  Map<String, dynamic> toMap() => {
        'category': category, 'question': question, 'answer': answer,
      };

  factory Faq.fromMap(String id, Map<String, dynamic> m) => Faq(
        category: m['category'] ?? 'Gerais',
        question: m['question'] ?? '',
        answer: m['answer'] ?? '');
}
