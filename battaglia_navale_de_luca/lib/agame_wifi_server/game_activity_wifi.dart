import 'dart:io';
import 'package:battaglia_navale_de_luca/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../board_square.dart';
import '../boards.dart' as boards;

// Types of images available
enum ImageType { ship, shipHitted, water, waterHitted }

class GameActivityWifi extends StatefulWidget {
  @override
  _GameActivityWifiState createState() => _GameActivityWifiState();
}

class _GameActivityWifiState extends State<GameActivityWifi> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Socket socket;
  bool connected = true;
  bool canPlay = true;
  // "hitted" refers to being clicked already
  List<bool> hittedSquares;
  String against;
  String username;
  // Probability that a square will be a bomb

  int bombCount = 0;
  int squaresLeft;

  @override
  Future<void> initState() {
    super.initState();
    _initialiseGame();
  }

// Initialises all lists
  Future<void> _initialiseGame() async {
    // Resets bomb count
    bombCount = 0;
    squaresLeft = boards.rowCount * boards.columnCount;

    setState(() {});
    final SharedPreferences prefs = await _prefs;
    username = prefs.getString("username");
    against = prefs.getString("against");

    //save to prefs a board for debug and restore
    /* if (prefs.getString("boards") != null)
      boards.myboard = stringToBoard(prefs.getString("boards"));
    else {
      String actualBoard = boardToString(boards.myboard);
      prefs.setString("boards", actualBoard);
    }
    setState(() {}); */

    /* printBoard(boards.myboard); //TEST board to string conversion
    String test=boardToString(boards.myboard);
    List<List<BoardSquare>> copy=stringToBoard(test);
    printBoard(copy); */

    connect();
  }

  void connect() async {
    await Socket.connect("deluca.pro", 1010).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      connected = true;
    }).catchError((Object e) {
      print("Unable to connect: $e");
    });
  }

  void doneHandler() {
    socket.destroy();
    connected = false;
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  Future dataHandler(msgR) async {
    String messages = new String.fromCharCodes(msgR).trim();
    var message = messages.split(';');
    message.forEach((f) {
      var tb = f.split(':');
      if (tb[0] == against && tb[1] == username) {
        switch (tb[2]) {
          case "SENDXY":
            boards.myboard[int.parse(tb[3])][int.parse(tb[4])].hitted = true;
            break;
          case "SENDTB":
            List<List<BoardSquare>> temp = stringToBoard(tb[3]);
            for (int l1 = 0; l1 < 10; l1++) {
              for (int l2 = 0; l2 < 10; l2++) {
                if (temp[l1][l2].isShip) {
                  boards.enemyBoard[l1][l2].isShip = true;
                  boards.enemyBoard[l2][l2].shipNumber =
                      temp[l1][l2].shipNumber;
                }
              }
            }
            break;
          case "TURNPASS":
            canPlay = true;
            break;
          case "YOULOSE":
            _handleGameOver();
            break;
          case "YOUWIN":
            _handleWin();
            break;
        }
      }
      setState(() {});
    });
  }

  void printBoard(List<List<BoardSquare>> board) {
    for (int l1 = 0; l1 < 10; l1++) {
      String row = "";
      for (int l2 = 0; l2 < 10; l2++) {
        row += board.elementAt(l1).elementAt(l2).isShip ? '1' : '0';
      }
      print(row);
    }
  }

  String boardToString(List<List<BoardSquare>> board) {
    String ris = "[";
    for (int l1 = 0; l1 < 10; l1++) {
      for (int l2 = 0; l2 < 10; l2++) {
        ris += board.elementAt(l1).elementAt(l2).isShip
            ? board.elementAt(l1).elementAt(l2).shipNumber.toString()
            : '0';
        if (l1 != 9 || l2 != 9)
          ris += ',';
        else
          ris += ']';
      }
    }
    return ris;
  }

  List<List<BoardSquare>> stringToBoard(String str) {
    List<List<BoardSquare>> ris = List.generate(boards.rowCount, (i) {
      return List.generate(boards.columnCount, (j) {
        return BoardSquare();
      });
    });

    int l1 = 0, l2 = 0, i = 0;
    while (l1 < 10) {
      if (str[i] != '[' && str[i] != ',') {
        //number of the table
        var cellInt = int.parse(str[i]);
        if (cellInt != 0) {
          ris.elementAt(l1).elementAt(l2).isShip = true;
          ris.elementAt(l1).elementAt(l2).shipNumber = cellInt;
        }
        i++;
        l2++;
        if (l2 == 10) {
          l2 = 0;
          l1++;
        }
      } else {
        i++;
      }
    }
    return ris;
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {
                    _initialiseGame();
                  },
                  child: Text(canPlay ? "YOUR TURN" : "ENEMY TURN",
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
                int rowNumber = (position / boards.columnCount).floor();
                int columnNumber = (position % boards.columnCount);

                Image image;

                if (boards.enemyBoard[rowNumber][columnNumber].isShip) {
                  if (boards.enemyBoard[rowNumber][columnNumber].hitted)
                    image = getImage(ImageType.shipHitted);
                  else
                    image = getImage(ImageType.water); //hidden ship
                } else {
                  if (boards.enemyBoard[rowNumber][columnNumber].hitted)
                    image = getImage(ImageType.waterHitted);
                  else
                    image = getImage(ImageType.water);
                }

                return InkWell(
                  // Opens square
                  onTap: () {
                    if (canPlay) {
                      canPlay = false;
                      if (!boards.enemyBoard[rowNumber][columnNumber].hitted) {
                        setState(() {
                          boards.enemyBoard[rowNumber][columnNumber].hitted =
                              true;
                        });
                      }
                      socket.write(username +
                          ":" +
                          against +
                          ":" +
                          "SENDXY" +
                          ":" +
                          rowNumber.toString() +
                          ":" +
                          columnNumber.toString() +
                          ";");
                      socket.write(username +
                          ":" +
                          against +
                          ":" +
                          "SENDTB" +
                          ":" +
                          boardToString(boards.myboard) +
                          ";");
                      socket.write(
                          username + ":" + against + ":" + "TURNPASS" + ";");
                      checkWin();
                    }
                  },
                  splashColor: Colors.grey,
                  child: Container(
                    color: Colors.grey,
                    child: image,
                  ),
                );
              },
              itemCount: boards.rowCount * boards.columnCount,
            ),
          ),
          //enemy grid
          Row(
            children: [
              Container(
                margin: const EdgeInsets.all(10.0),
                color: Colors.transparent, //Colors.amber[600],
                width: MediaQuery.of(context).size.width / 3,
                height: 48.0,
                child: Center(
                  child: Text(
                    countHitted(boards.myboard).toString() +
                        ":" +
                        countHitted(boards.enemyBoard).toString(),
                    style: TextStyle(
                        fontSize: 45,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                color: Colors.amber[600],
                width: MediaQuery.of(context).size.height / 4,
                height: MediaQuery.of(context).size.height / 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: boards.columnCount,
                    ),
                    itemBuilder: (context, position) {
                      // Get row and column number of square
                      int rowNumber = (position / boards.columnCount).floor();
                      int columnNumber = (position % boards.columnCount);

                      Image image;

                      if (boards.myboard[rowNumber][columnNumber].isShip) {
                        if (boards.myboard[rowNumber][columnNumber].hitted)
                          image = getImage(ImageType.shipHitted);
                        else
                          image = getImage(ImageType.ship);
                      } else {
                        if (boards.myboard[rowNumber][columnNumber].hitted)
                          image = getImage(ImageType.waterHitted);
                        else
                          image = getImage(ImageType.water);
                      }

                      return Container(
                        color: Colors.grey,
                        child: image,
                      );
                    },
                    itemCount: boards.rowCount * boards.columnCount,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int countHitted(List<List<BoardSquare>> board) {
    int ris = 0;
    for (int l1 = 0; l1 < 10; l1++) {
      for (int l2 = 0; l2 < 10; l2++) {
        if (board[l1][l2].isShip && board[l1][l2].hitted) ris++;
      }
    }
    return ris;
  }

  void checkWin() {
    bool shipNotHitted = false;
    for (int l1 = 0; l1 < 10; l1++) {
      for (int l2 = 0; l2 < 10; l2++) {
        if (boards.myboard[l1][l2].isShip && !boards.myboard[l1][l2].hitted)
          shipNotHitted = true;
      }
    }
    if (!shipNotHitted) _handleGameOver();
  }

  // Function to handle when you lose.
  void _handleGameOver() {
    socket.write(username + ":" + against + ":" + "YOUWIN" + ";");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over!"),
          content: Text("You noob!"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _initialiseGame();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
              child: Text("Play again"),
            ),
          ],
        );
      },
    );
  }

  void _handleWin() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text("You Win!"),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _initialiseGame();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
              child: Text("Play again"),
            ),
          ],
        );
      },
    );
  }
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
