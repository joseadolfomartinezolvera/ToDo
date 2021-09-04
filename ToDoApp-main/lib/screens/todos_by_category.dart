import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/services/todo_service.dart';

class TodosByCategory extends StatefulWidget {
  final String category;

  TodosByCategory({this.category});

  @override
  _TodosByCategoryState createState() => _TodosByCategoryState();
}

class _TodosByCategoryState extends State<TodosByCategory> {
  List<Todo> _todoList = List<Todo>.empty(growable: true);
  TodoService _todoService = TodoService();

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  getTodosByCategory() async {
    var todos = await _todoService.todosByCategory(this.widget.category);
    todos.forEach((todo) {
      setState(() {
        var model = Todo();
        model.title = todo["title"];
        model.id = todo["id"];
        _todoList.add(model);
      });
    });
  }

  _deleteTodoDialog(BuildContext context, TodoId) {
    //Dialogo para borrar un elemento
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (param) {
          return AlertDialog(
            // Se genera a partir de sus partes
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Se coloca estilo para mejorar la experiencia
                  primary: Colors.green, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () async {

                  print(TodoId);
                  var _todoService = TodoService();
                  // Al presionar borrar se eliminara el registro
                  var result = await _todoService.deleteTodos(TodoId);
                  print(result);
                  if (result > 0) {
                    // Permitirá actualizar la lista con el cambio realizado
                    Navigator.pop(context);
                    setState(() {
                      _todoList.clear();
                    });
                    getTodosByCategory();
                    _showSnackBar('Deleted!');
                  }
                },
                child: Text('Delete'),
              ),
            ],
            title: Text("Are you sure you want to delete?"),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getTodosByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todos by category"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 0),
                          blurRadius: 1.0,
                          spreadRadius: 0.0)
                    ],
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.all(Radius.circular(3.0))),
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(4.0),
                child: Text(this.widget.category,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white)),
              )),
          Expanded(
            flex: 12,
            child: ListView.builder(
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(_todoList[index].title ?? "No title"),
                          IconButton(
                              // Tanto el botón de editar y borrar mostrarán un cuadro de dialogo
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              //Que contienen los botones para cancelar o realizar la operación
                              onPressed: () {
                                _deleteTodoDialog(context, _todoList[index].id);
                              })
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
