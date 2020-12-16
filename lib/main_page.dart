import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/models/grid.dart';

import 'models/grid_content.dart';

class GridPage extends StatefulWidget {
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  Grid grid;

  @override
  void initState() {
    super.initState();
    grid = Grid.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder(
            future: grid.loadJSON("assets/json/test_grid.json"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GridUIView(
                    grid.gridColumns, grid.gridRows, grid.gridCombinedGroups);
              } else {
                return Container();
              }
            }),
      ),
    );
  }
}
