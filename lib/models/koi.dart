class Koi {
  final String id;
  final String name;
  final String variety;
  final String breeder;
  final String lineage;
  final double size;
  final int age;
  final String? photoPath;

  Koi({
    required this.id,
    required this.name,
    required this.variety,
    required this.breeder,
    required this.lineage,
    required this.size,
    required this.age,
    this.photoPath,
  });
}
