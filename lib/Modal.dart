import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Expense.dart';
import 'ExpensesModel.dart';
import 'package:intl/intl.dart';

class _ModalState extends State<Modal> {
  Expense expense;
  ExpensesModel _model;

  final format = DateFormat('dd-MM-yyyy');
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double _price;
  String _name;
  DateTime _dateTime;

  _ModalState(this._model);

  @override
  Widget build(BuildContext context) {
    expense = ModalRoute.of(context).settings.arguments;
    var appBarTitle = expense == null ? 'Add Expense' : 'Editing';
    var bottomTitle = expense == null ? 'Add' : 'Save';
    var dateWidget = expense == null
        ? SizedBox.shrink()
        : (Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Text('Date')),
              SizedBox(
                width: 300,
                child: DateTimeField(
                  format: format,
                  initialValue: expense.date,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1901),
                        initialDate: currentValue,
                        lastDate: DateTime(2099));
                  },
                  onSaved: (value) {
                    _dateTime = value;
                  },
                  validator: (value) {
                    if (value != null) {
                      return null;
                    } else {
                      return 'Date must not be empty!';
                    }
                  },
                ),
              )
            ],
          ));
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
            key: _formKey,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text('Value')),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      autovalidate: true,
                      initialValue:
                          expense == null ? '0' : expense.price.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (value) {
                        _price = double.parse(value);
                      },
                      validator: (value) {
                        if (double.tryParse(value) != null) {
                          return null;
                        } else {
                          return 'Enter the valid price!';
                        }
                      },
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text('Name')),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      initialValue: expense == null ? 'Name' : expense.name,
                      onSaved: (value) {
                        _name = value;
                      },
                      validator: (value) {
                        if (value.isNotEmpty) {
                          return null;
                        } else {
                          return 'Name must not be empty!';
                        }
                      },
                    ),
                  )
                ],
              ),
              dateWidget,
              Padding(
                padding: const EdgeInsets.all(20),
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();

                      if (expense != null) {
                        _model.editExpense(
                            expense.id, _name, _price, _dateTime);
                      } else {
                        _model.addExpense(_name, _price);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: SizedBox(
                      width: 200, child: Center(child: Text(bottomTitle))),
                ),
              )
            ])),
      ),
    );
  }
}

class Modal extends StatefulWidget {
  final ExpensesModel _model;

  Modal(this._model);

  @override
  State<StatefulWidget> createState() {
    return _ModalState(_model);
  }
}
