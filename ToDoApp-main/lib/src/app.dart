import 'package:flutter/material.dart';
import 'package:todo_app/screens/home_screen.dart';

class App extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(
        primarySwatch: Colors.teal
      ),
    );
  }
}