import 'package:battaglia_navale_de_luca/agame_wifi_server/game_activity_wifi.dart';
import 'package:battaglia_navale_de_luca/agame_wifi_server/pre_game_wifi.dart';
import 'package:flutter/material.dart';
import 'package:battaglia_navale_de_luca/board_square.dart';
import 'boat.dart';
import 'boards.dart' as boards;

// Types of images available
enum ImageType { ship, shipHitted, water, waterHitted }

class PrepareGrid extends StatefulWidget {
  @override
  _PrepareGridState createState() => _PrepareGridState();
}

class _PrepareGridState extends State<PrepareGrid> {
  List<Boat> avaibleBoats = [];

  bool acceptDrag = true;
  // Row and column count of the board
  double cellSide = 10;
  double gridBorderPadding = 15;

  // The grid of squares
  List<List<BoardSquare>> board;
  List<List<BoardSquare>> enemyBoard;

  // "hitted" refers to being clicked already
  List<bool> hittedSquares;

  // Probability that a square will be a bomb
  int bombProbability = 3;
  int maxProbability = 15;

  int bombCount = 0;
  int squaresLeft;

  @override
  void initState() {
    super.initState();
    prepareGrid();
  }

  canDropOn(x, y) {
    return true;
  }

  prepareGrid() {
    boards.myboard = List.generate(boards.rowCount, (i) {
      return List.generate(boards.columnCount, (j) {
        return BoardSquare();
      });
    });

    boards.enemyBoard = List.generate(boards.rowCount, (i) {
      return List.generate(boards.columnCount, (j) {
        return BoardSquare();
      });
    });

    avaibleBoats = [
      Boat(shipLenght: 2, shipNumber: 1),
      Boat(shipLenght: 3, shipNumber: 2),
      Boat(shipLenght: 4, shipNumber: 3)
    ];

    setState(() {});
  }

  addBoat(int rowNumber, int columnNumber, int shipLenght,
      bool shipOrientationHorizontal, int shipNumber) {
    for (int y = 0, x = 0; x < shipLenght && y < shipLenght;) {
      boards.myboard
          .elementAt(rowNumber + y)
          .elementAt(columnNumber + x)
          .isShip = true;

      boards.myboard
          .elementAt(rowNumber + y)
          .elementAt(columnNumber + x)
          .shipNumber = shipNumber;
      boards.myboard
          .elementAt(rowNumber + y)
          .elementAt(columnNumber + x)
          .shipLenght = shipLenght;
      boards.myboard
          .elementAt(rowNumber + y)
          .elementAt(columnNumber + x)
          .progressiveNumber = shipOrientationHorizontal ? x : y;
      boards.myboard
          .elementAt(rowNumber + y)
          .elementAt(columnNumber + x)
          .shipOrientationHorizontal = shipOrientationHorizontal;

      if (shipOrientationHorizontal)
        x++;
      else
        y++;
    }
  }

  @override
  Widget build(BuildContext context) {
    cellSide = MediaQuery.of(context).size.height -
        gridBorderPadding / boards.columnCount;
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.transparent,
            height: 60.0,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {prepareGrid();},
                  child: Text("RESET",
                      style: TextStyle(
                          fontSize: 45,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w900)),
                )
              ],
            ),
          ),
          // this grid
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: boards.columnCount,
              ),
              itemBuilder: (context, position) {
                // Get row and column number of square
                int rowNumber = (position / boards.columnCount).floor(); //y
                int columnNumber = (position % boards.columnCount); //x

                Image image = getImage(ImageType.water);
                Image imageShip = getImage(ImageType.ship);

                return DragTarget<Boat>(
                  builder: (context, candidateData, rejectedData) {
                    return !boards.myboard
                            .elementAt(rowNumber)
                            .elementAt(columnNumber)
                            .isShip
                        ? Container(
                            color: Colors.grey,
                            child: image,
                          )
                        : Container(
                            color: Colors.yellow,
                          );
                  },
                  onWillAccept: (Boat data) {
                    acceptDrag = true;
                    for (int y = 0, x = 0;
                        x < data.shipLenght && y < data.shipLenght;) {
                      if (!(rowNumber + y < 10 && columnNumber + x < 10) ||
                          boards.myboard
                              .elementAt(rowNumber + y)
                              .elementAt(columnNumber + x)
                              .isShip) acceptDrag = false;

                      if (data.shipOrientationHorizontal)
                        x++;
                      else
                        y++;
                    }
                    return acceptDrag;
                  },
                  onAccept: (Boat data) {
                    addBoat(rowNumber, columnNumber, data.shipLenght,
                        data.shipOrientationHorizontal, data.shipNumber);
                    avaibleBoats.remove(data);
                    if (avaibleBoats.isEmpty)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreGameWifi(),
                        ),
                      );
                    setState(() {});
                  },
                );
              },
              itemCount: boards.rowCount * boards.columnCount,
            ),
          ),

          //boat list grid
          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                child: new Center(
                  child: new Column(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                            height: 200.0,
                            child: new ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: avaibleBoats.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      avaibleBoats[index]
                                              .shipOrientationHorizontal =
                                          !avaibleBoats[index]
                                              .shipOrientationHorizontal;
                                      setState(() {});
                                    },
                                    child: Draggable<Boat>(
                                      data: avaibleBoats[index],
                                      child: Container(
                                        width: 100,
                                        height: 200,
                                        child: Stack(
                                          children: <Widget>[
                                            Center(
                                              child: Image.asset(
                                                avaibleBoats[index]
                                                        .shipOrientationHorizontal
                                                    ? 'images/selectionsShip90.png'
                                                    : 'images/selectionsShip.png',
                                                width: 100,
                                                height: 200,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                  avaibleBoats[index]
                                                      .shipLenght
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 56,
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      childWhenDragging: Image.asset(
                                        'images/selectionsRow.png',
                                        width: 100,
                                        height: 200,
                                      ),
                                      feedback: Image.asset(
                                        avaibleBoats[index]
                                                .shipOrientationHorizontal
                                            ? 'images/selectionsRow90.png'
                                            : 'images/selectionsRow180.png',
                                        width: 0,
                                        height: 0,
                                      ),
                                    ),
                                  );
                                })),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Image getImage(ImageType type) {
    switch (type) {
      case ImageType.ship:
        return Image.asset('images/ship.png');
      case ImageType.shipHitted:
        return Image.asset('images/shipHitted.png');
      case ImageType.water:
        return Image.asset('images/water.png');
      case ImageType.waterHitted:
        return Image.asset('images/waterHitted.png');
      default:
        return null;
    }
  }
}
