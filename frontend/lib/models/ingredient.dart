/// Ingredient model
class Ingredient {
  final String name;
  final String? id;

  const Ingredient({required this.name, this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => name;
}
