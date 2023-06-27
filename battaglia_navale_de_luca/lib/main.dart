import 'package:battaglia_navale_de_luca/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:battaglia_navale_de_luca/utilities/constants.dart';
import 'board_square.dart';
import 'boards.dart' as boards;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    // Initialise all squares to having no ship
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: kTooltipColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: Color(0xFF4225A0),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'AmaticSC'),
      ),
      initialRoute: 'homePage',
      routes: {
        'homePage': (context) => HomeScreen(),
        },
    );
  }
}