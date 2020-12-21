import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/models/grid.dart';

class GridPage extends StatefulWidget {
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  Grid grid;
  GridUIView gridView;
  String path;

  @override
  void initState() {
    super.initState();
    print("new");
    grid = Grid.getInstance();
    grid.loadJSON("assets/json/test_grid.json").then((value) {
      setState(() {
        grid.gridColumns = value.gridColumns;
        grid.gridRows = value.gridRows;
        grid.combinedGroups = value.combinedGroups;

        gridView =
            GridUIView(grid.gridColumns, grid.gridRows, grid.combinedGroups);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              grid.combinedGroups == null
                  ? CircularProgressIndicator()
                  : gridView,
              Container(
                child: Row(
                  children: [
                    FlatButton(
                      color: Colors.white,
                      child: Text(
                        "Change",
                      ),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            gridView.change(9);
                          });
                        });
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
