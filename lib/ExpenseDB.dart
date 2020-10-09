import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Expense.dart';

class ExpenseDB {
  Database _database;

  Future<Database> get database async { 
    if (_database == null) {
      _database = await initialize();
    }
    return _database;
  }

  ExpenseDB() {}

  dynamic initialize() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    var path = Path.join(documentsDir.path, 'db.db');
    return openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE Expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, price REAL, date TEXT, name TEXT)');
      },
    );
  }

  Future<List<Expense>> getAllExpenses() async {
    Database db = await database;
    List<Map> query = await db.rawQuery('SELECT * FROM Expenses ORDER BY date DESC');
    List<Expense> result = List<Expense>();
    query.forEach((element) {
      result.add(Expense(element['id'], DateTime.parse(element['date']), element['name'], element['price']));
    });
    return result;
  }

  Future<void> addExpense(String name, double price, DateTime date) async {
    Database db = await database;
    var dateStr = date.toString();
    db.rawInsert("INSERT INTO Expenses (name, price, date) VALUES (\"$name\", \"$price\", \"$dateStr\")");
  }

  Future<void> removeExpense(int id) async {
    Database db = await database;
    db.rawDelete('DELETE FROM Expenses WHERE id = $id');
  }

  Future<void> editExpense(int id, String name, double price, DateTime date) async {
    Database db = await database;
    var dateStr = date.toString();
    db.rawUpdate("UPDATE Expenses SET name = \"$name\", price = \"$price\", date = \"$dateStr\" WHERE id = \"$id\"");
  }
}
