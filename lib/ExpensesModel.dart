import 'package:paytracker1/Expense.dart';
import 'package:paytracker1/ExpenseDB.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

class ExpensesModel extends Model {
  List<Expense> _items = [
    // Expense(1, DateTime.now(), 'car', 1000),
    // Expense(2, DateTime.now(), 'food', 154),
    // Expense(3, DateTime.now(), 'stuff', 788),
  ];

  ExpenseDB _database;

  int get recordsCount => _items.length;

  ExpensesModel() {
    _database = ExpenseDB();
    load();
  }

  void load() {
    Future<List<Expense>> future = _database.getAllExpenses();
    future.then((list) {
      _items = list;
      notifyListeners();
    });
  }

  String getKey(int idx) => _items[idx].id.toString();

  String getText(int idx) {
    var e = _items[idx];
    var d = new DateFormat.yMd().format(e.date);
    return e.name +
        ' for ' +
        e.price.toStringAsFixed(0) +
        '\nat ' +
        d.toString();
  }

  String getTotalExpenses() {
    double res = 0;
    _items.forEach((element) {
      res += element.price;
    });
    return res.toStringAsFixed(0);
  }

  void filterList(int month) async {
    Future<List<Expense>> e = _database.getAllExpenses();
    e.then((element) {
      if (month == 0) {
        _items = element;
      } else {
        _items = element.where((element) => element.date.month == month).toList();
      }
      notifyListeners();
    });
  }

  Expense getItem(int idx) => _items[idx];

  void removeExpense(int idx) {
    int id = _items[idx].id;
    Future<void> future = _database.removeExpense(id);
    future.then((_) {
      load();
    });
  }

  void addExpense(String name, double price) {
    Future<void> future = _database.addExpense(name, price, DateTime.now());
    future.then((_) {
      load();
    });
  }

  void editExpense(int id, String name, double price, DateTime time) {
    Future<void> future = _database.editExpense(id, name, price, time);
    future.then((value) {
      load();
    });
  }
}
