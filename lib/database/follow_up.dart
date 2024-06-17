import 'package:hive/hive.dart';
import 'customer.dart';

part 'follow_up.g.dart';

@HiveType(typeId: 6)
class FollowUp extends HiveObject {
  @HiveField(0)
  final Customer customer;

  @HiveField(1)
  final DateTime followUpDate;

  FollowUp({
    required this.customer,
    required this.followUpDate,
  });
}
