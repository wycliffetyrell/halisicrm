import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 4)
class Product extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  double priceInKsh;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceInKsh,
  });
}
