import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/helpers/drawer_navigation.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/screens/todos_screen.dart';
import 'package:todo_app/services/todo_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TodoService _todoService;
  List<Todo> _todoList = List<Todo>.empty(growable: true);

  @override
  void initState(){
    super.initState();
    getAllTodos();
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  getAllTodos() async{
    _todoService = TodoService();
    //_todoList = List<Todo>.empty(growable: true);
    var todos = await _todoService.getTodos();
    todos.forEach(
            (todo){
          setState(() {
            var model = Todo();
            model.id = todo["id"];
            model.title = todo["title"];
            model.description = todo["description"];
            model.category = todo["category"];
            model.todoDate = todo["todoDate"];
            model.isFinished = todo["isFinished"];
            _todoList.add(model);
          });
        }
    );
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
                  var _todoService = TodoService();
                  // Al presionar borrar se eliminara el registro
                  var result =
                  await _todoService.deleteTodos(TodoId);
                  if (result > 0) {
                    // Permitirá actualizar la lista con el cambio realizado
                    Navigator.pop(context);
                    setState(() {
                      _todoList.clear();
                    });
                    getAllTodos();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My ToDo App"),
      ),
      body: ListView.builder(
          itemCount: _todoList.length,
          itemBuilder: (context, index){
            return Card(
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_todoList[index].title ?? "No title"),
                    IconButton(
                      // Tanto el botón de editar y borrar mostrarán un cuadro de dialogo
                        icon: Icon(Icons.delete,color: Colors.redAccent),
                        //Que contienen los botones para cancelar o realizar la operación
                        onPressed: () {
                          _deleteTodoDialog(
                              context, _todoList[index].id);
                        })
                  ],
                ),
              ),
            );
          }),
      drawer: DrawerNavigation(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ToDosScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
