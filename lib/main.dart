import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GridUI implementation',
      theme: ThemeData(fontFamily: 'DMMono-Regular'),
      home: GridPage(),
    );
  }
}
