import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/expenses.dart';

class ExpenseProvider extends ChangeNotifier {
  static const _boxName = 'expensesBox';
  List<Expense> _expenses = [];

  String? _filterCategory;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool _sortByAmount = false;

  List<Expense> get expenses {
    var filtered = _expenses.where((expense) {
      bool matchesCategory = _filterCategory == null || expense.category == _filterCategory;
      bool matchesStartDate = _filterStartDate == null || expense.date.isAfter(_filterStartDate!.subtract(const Duration(days:1)));
      bool matchesEndDate = _filterEndDate == null || expense.date.isBefore(_filterEndDate!.add(const Duration(days:1)));
      return matchesCategory && matchesStartDate && matchesEndDate;
    }).toList();

    filtered.sort((a, b) {
      if (_sortByAmount) {
        return b.amount.compareTo(a.amount);
      } else {
        return b.date.compareTo(a.date);
      }
    });

    return filtered;
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setFilterDateRange(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    notifyListeners();
  }

  void setSortByAmount(bool value) {
    _sortByAmount = value;
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    final box = await Hive.openBox<Expense>(_boxName);
    _expenses = box.values.toList();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    final box = await Hive.openBox<Expense>(_boxName);
    await box.add(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
    await loadExpenses();
  }

  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
    await loadExpenses();
  }
}
