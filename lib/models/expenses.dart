import 'package:hive/hive.dart';

part 'expenses.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  Expense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });
}
