/// Papel do usuário. `admin` = Setor de Estágios (cadastra vagas — ver spec §4).
enum AuthRole { student, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final AuthRole role;

  const AppUser({required this.id, required this.name, required this.email, this.role = AuthRole.student});

  AppUser copyWith({String? name, AuthRole? role}) =>
      AppUser(id: id, name: name ?? this.name, email: email, role: role ?? this.role);

  @override
  bool operator ==(Object other) =>
      other is AppUser && other.id == id && other.name == name && other.email == email && other.role == role;

  @override
  int get hashCode => Object.hash(id, name, email, role);
}
