enum BenefitKind { gov, inst }

class Benefit {
  final String icon, title, tag, description;
  final List<String> steps; // forma de obtenção (RF011)
  const Benefit({
    required this.icon, required this.title, required this.tag,
    required this.description, required this.steps,
  });
}
