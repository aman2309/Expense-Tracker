import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tracker/screens/summary_screen.dart';

import '../provider/expense_provider.dart';
import '../screens/add_edit_expense_screen.dart';
import '../models/expenses.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  bool sortByAmount = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
    });
  }

  Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Travel': Icons.flight_takeoff,
    'Other': Icons.category,
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;
    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Entertainment',
      'Health',
      'Travel',
      'Other'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Your Expense Tracker',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.black),
            tooltip: 'View Summary',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SummaryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showFilterOptions(context, categories);
                  },
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  label: Text(
                    selectedCategory ?? 'Filter',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(width: 16),

                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      sortByAmount = !sortByAmount;
                      provider.setSortByAmount(sortByAmount);
                    });
                  },
                  icon: Icon(
                    sortByAmount ? Icons.sort_by_alpha : Icons.attach_money,
                    color: Colors.black,
                  ),
                  label: Text(
                    sortByAmount ? 'Sort by Date' : 'Sort by Amount',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child:
                expenses.isEmpty
                    ? const Center(
                      child: Text(
                        'No expenses yet',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final e = expenses[index];
                        return Card(
                          color: Colors.black,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                categoryIcons[e.category] ?? Icons.category,
                                color: Colors.black,
                              ),
                            ),
                            title: Text(
                              e.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.category,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat.yMMMd().format(e.date),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '\₹${e.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddEditExpenseScreen(expense: e),
                                ),
                              );
                            },
                            onLongPress: () {
                              _confirmDelete(context, e, provider);
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, List<String> categories) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String? tempSelectedCategory =
            selectedCategory; // temp holder for modal
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ...[null, ...categories].map((cat) {
                    final label = cat ?? 'All';
                    final isSelected = tempSelectedCategory == cat;
                    return ListTile(
                      title: Text(label),
                      trailing:
                          isSelected
                              ? const Icon(Icons.check, color: Colors.black)
                              : null,
                      onTap: () {
                        setModalState(() {
                          tempSelectedCategory = cat;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            selectedCategory = tempSelectedCategory;
                            provider.setFilterCategory(selectedCategory);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    Expense e,
    ExpenseProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Delete Expense',
              style: TextStyle(color: Colors.black),
            ),
            content: const Text(
              'Are you sure you want to delete this expense?',
              style: TextStyle(color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await provider.deleteExpense(e);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
