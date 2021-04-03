import 'package:flutter/material.dart';
import 'package:grid_ui_implementation/custom_views/grid_view.dart';
import 'package:grid_ui_implementation/models/grid.dart';
import 'package:http/http.dart' as http;
import 'network_config.dart';

class GridPage extends StatefulWidget {
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  Grid grid;
  GridUIView gridView;

  @override
  void initState() {
    super.initState();
    grid = Grid.getInstance();
    grid.initGridView("assets/json/test_grid.json").then((value) {
      setState(() {
        gridView = value;
      });
    });
  }

  ///Retrieve a Grid layout from the url specified
  Future<String> getGridFromServer(String url) async {
    if (url != "" && url.isEmpty) {
      throw Exception("URL value required");
    } else {
      http.Response response = await http.get(url);
      String grid;

      if (response.statusCode == 200) {
        grid = response.body;
      } else {
        grid = '';
      }

      return grid;
    }
  }

  Widget loadGridView(GridUIView gridView) {
    return grid.combinedGroups == null ? CircularProgressIndicator() : gridView;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              /* ====
               * Grid
               =====*/
              loadGridView(gridView),

              /* ==============
               * Bottom buttons
               ===============*/
              Container(
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      color: Colors.white,
                      child: Text(
                        "Default",
                      ),
                      onPressed: () {
                        getGridFromServer(
                                'http://${Config.serverAddr}:${Config.serverPort}/default')
                            .then((value1) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value1)
                              .then((value) {
                            setState(() {
                              grid.grid_json = value1;
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                            gridView.changeGridJSON(grid.grid_json);
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
                        getGridFromServer(
                                'http://${Config.serverAddr}:${Config.serverPort}/preset1')
                            .then((value1) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value1)
                              .then((value) {
                            setState(() {
                              grid.grid_json = value1;
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                            gridView.changeGridJSON(grid.grid_json);
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
                        getGridFromServer(
                                'http://${Config.serverAddr}:${Config.serverPort}/preset2')
                            .then((value1) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value1)
                              .then((value) {
                            setState(() {
                              grid.grid_json = value1;
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                            gridView.changeGridJSON(grid.grid_json);
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
                        getGridFromServer(
                                'http://${Config.serverAddr}:${Config.serverPort}/preset3')
                            .then((value1) {
                          grid
                              .loadJSON("", fromNetwork: true, grid: value1)
                              .then((value) {
                            setState(() {
                              grid.grid_json = value1;
                              grid.gridColumns = value.gridColumns;
                              grid.gridRows = value.gridRows;
                              grid.combinedGroups = value.combinedGroups;
                            });
                          });

                          setState(() {
                            gridView.changeCols(grid.gridColumns);
                            gridView.changeRows(grid.gridRows);
                            gridView.changeGrid(grid.combinedGroups);
                            gridView.changeGridJSON(grid.grid_json);
                          });
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.white,
                      child: Text("Toggle edit mode"),
                      onPressed: () {
                        setState(() {
                          gridView.state.editMode = !gridView.state.editMode;
                          gridView.changeEditMode(gridView.state.editMode);
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.white,
                      child: Text("Create combined block"),
                      onPressed: () {
                        gridView.createCombinedBlockialog(context);
                      },
                    ),
                    FlatButton(
                      color: Colors.white,
                      child: Text("Delete combined block"),
                      onPressed: () {
                        gridView.deleteCombinedBlockialog(context);
                      },
                    ),
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
