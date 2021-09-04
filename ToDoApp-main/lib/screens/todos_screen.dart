import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/category_service.dart';
import 'package:todo_app/services/todo_service.dart';

import 'home_screen.dart';

class ToDosScreen extends StatefulWidget {
  const ToDosScreen({Key key}) : super(key: key);

  @override
  _ToDosScreenState createState() => _ToDosScreenState();
}

class _ToDosScreenState extends State<ToDosScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  var _todoTitle = TextEditingController();
  var _todoDescription = TextEditingController();
  var _todoDate = TextEditingController();
  var _selectedValue;
  var paddingElement = 10.0;

  List<DropdownMenuItem> _categories =
  List<DropdownMenuItem>.empty(growable: true);

  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _selectTodoDate() async {
    var _pickedDate = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2099));
    if (_pickedDate != null) {
      setState(() {
        _date = _pickedDate;
        _todoDate.text = DateFormat("yyyy-MM-dd").format(_pickedDate);
      });
    }
  }

  _loadCategories() async {
    var _categoryService = CategoryService();
    var categories = await _categoryService.getCategories();
    categories.forEach((category) {
      setState(() {
        _categories.add(DropdownMenuItem(
          child: Text(category["name"]),
          value: category["name"],
        ));
      });
    });
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: Text("Create Todo"),
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(paddingElement),
              child: TextField(
                  controller: _todoTitle,
                  decoration: InputDecoration(
                      hintText: "Write ToDo Title",
                      labelText: "ToDo Title",
                      prefixIcon: Icon(Icons.title)))),
          Container(
              padding: EdgeInsets.all(paddingElement),
              child: TextField(
                  controller: _todoDescription,
                  decoration: InputDecoration(
                      hintText: "Write ToDo Description",
                      labelText: "ToDo Description",
                      prefixIcon: Icon(Icons.description)))),
          Container(
              padding: EdgeInsets.all(paddingElement),
              child: TextField(
                  controller: _todoDate,
                  decoration: InputDecoration(
                      hintText: "YY-MM-DD",
                      labelText: "YY-MM-DD",
                      prefixIcon: InkWell(
                          child: Icon(Icons.calendar_today),
                          onTap: () {
                            _selectTodoDate();
                          })))),
          Container(
              padding: EdgeInsets.all(paddingElement),
              child: DropdownButtonFormField(
                decoration: InputDecoration(prefixIcon: Icon(Icons.category)),
                items: _categories,
                value: _selectedValue,
                hint: Text("Select a category"),
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
              )),
          Container(
              margin: EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  onPressed: () async {
                    var todoObj = Todo();
                    todoObj.title = _todoTitle.text;
                    todoObj.description = _todoDescription.text;
                    todoObj.todoDate = _todoDate.text;
                    todoObj.category = _selectedValue;
                    todoObj.isFinished = 0;
                    var _todoService = TodoService();
                    var result = await _todoService.insertTodo(todoObj);
                    if (result > 0) {
                      _todoTitle.text = "";
                      _todoDescription.text = "";
                      _todoDate.text = "";
                      _showSnackBar("Successful save!");
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                    }
                  },
                  child: Text("Save")))
        ],
      ),
    );
  }
}
