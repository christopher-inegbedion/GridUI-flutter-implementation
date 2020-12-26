import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:http/http.dart' as http;

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

  Future<String> getGridFromServer(String url) async {
    http.Response response = await http.get(url);
    String grid;

    if (response.statusCode == 200) {
      grid = response.body;
    } else {
      grid = '';
    }

    return grid;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              grid.combinedGroups == null
                  ? CircularProgressIndicator()
                  : gridView,
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                      color: Colors.white,
                      child: Text(
                        "Default",
                      ),
                      onPressed: () {
                        getGridFromServer('http://192.168.1.129:5000/default')
                            .then((value) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value)
                              .then((value) {
                            setState(() {
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                          });
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.white,
                      child: Text(
                        "Preset 1",
                      ),
                      onPressed: () {
                        getGridFromServer('http://192.168.1.129:5000/preset1')
                            .then((value) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value)
                              .then((value) {
                            setState(() {
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                          });
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.white,
                      child: Text(
                        "Preset 2",
                      ),
                      onPressed: () {
                        print(
                            "combined block start column ${grid.getBlockStartColumn(1, 2)}");
                        print(
                            "combined block start row ${grid.getBlockStartRow(1, 2)}");
                        getGridFromServer('http://192.168.1.129:5000/preset2')
                            .then((value) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value)
                              .then((value) {
                            setState(() {
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                          });
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.white,
                      child: Text(
                        "Preset 3",
                      ),
                      onPressed: () {
                        getGridFromServer('http://192.168.1.129:5000/preset3')
                            .then((value) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value)
                              .then((value) {
                            setState(() {
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                          });
                          ;
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
