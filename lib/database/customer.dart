import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String placeOfDelivery;

  @HiveField(4)
  final DateTime dateOfPurchase;

  Customer({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.placeOfDelivery,
    required this.dateOfPurchase,
    required key,
  });
}
