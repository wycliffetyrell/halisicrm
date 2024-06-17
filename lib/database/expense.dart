// models/expense.dart
import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  String type;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  Expense({required this.type, required this.amount, required this.date});
}
