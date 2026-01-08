/// Ingredient model
class Ingredient {
  final String name;
  final String? id;

  const Ingredient({required this.name, this.id});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(id: json['id'] as String?, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

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
