import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paytracker1/ExpensesModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Modal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpTracker',
      theme: new ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.cyan,
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: MyHomePage(title: 'ExpTracker'),
    );
  }
}

Widget slideLeftBackground() {
  return Container(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            ' Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}

class Month {
  final int id;
  final String name;

  Month(this.id, this.name);
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final List<Month> months = [
    Month(0, 'All Months'),
    Month(1, 'January'),
    Month(2, 'February'),
    Month(3, 'March'),
    Month(4, 'April'),
    Month(5, 'May'),
    Month(6, 'June'),
    Month(7, 'July'),
    Month(8, 'August'),
    Month(9, 'September'),
    Month(10, 'October'),
    Month(11, 'November'),
    Month(12, 'December'),
  ];

  Month dropdownValue;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ExpensesModel>(
      model: ExpensesModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            ScopedModelDescendant<ExpensesModel>(
              builder: (context, child, model) => DropdownButton<Month>(
                value: dropdownValue,
                hint: Text('Select Month'),
                icon: Icon(Icons.arrow_downward_sharp),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.cyan,
                ),
                onChanged: (Month newValue) {
                  dropdownValue = newValue;
                  model.filterList(newValue.id);
                },
                items: months.map((Month value) {
                  return DropdownMenuItem<Month>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
              ),
            )
          ],
        ),
        body: ScopedModelDescendant<ExpensesModel>(
          builder: (context, child, model) => ListView.separated(
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  String totalExpenses = model.getTotalExpenses();
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        text: 'Total expenses: ',
                        style: TextStyle(color: Colors.amber, fontSize: 22),
                        children: <TextSpan>[
                          TextSpan(
                              text: '$totalExpenses',
                              style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  );
                } else {
                  idx -= 1;
                  return Dismissible(
                      key: Key(model.getKey(idx)),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        model.removeExpense(idx);
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Expense was successfully deleted')));
                      },
                      child: ListTile(
                        title: Text(model.getText(idx),
                            style: TextStyle(
                                color: Colors.cyan, fontSize: 18, height: 2)),
                        // leading: Icon(Icons.attach_money),
                        leading: Icon(Icons.delete, color: Colors.brown),
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Modal(model);
                                },
                                settings: RouteSettings(
                                  arguments: model.getItem(idx),
                                ),
                              ));
                        },
                      ),
                      background: slideLeftBackground(),
                      confirmDismiss:
                          (DismissDirection dismissDirection) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm'),
                              content: const Text(
                                  'Are you sure you wish to delete this item?'),
                              actions: [
                                FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('DELETE')),
                                FlatButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('CANCEL'),
                                ),
                              ],
                            );
                          },
                        );
                      });
                }
              },
              separatorBuilder: (context, idx) => Divider(),
              itemCount: model.recordsCount + 1),
        ),
        floatingActionButton: ScopedModelDescendant<ExpensesModel>(
          builder: (context, child, model) => FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Modal(model);
              }));
              // model.addExpense("Apple", 10);
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
