import 'package:battaglia_navale_de_luca/prepare_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:battaglia_navale_de_luca/components/action_button.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController _controller,_controllerScale;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _controllerScale = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    animation = new CurvedAnimation(parent: _controllerScale, curve: Curves.linear);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return ScaleTransition(
      scale: animation,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  child: Text(
                    'SEA BATTLE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 55.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.015,
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    child: Image.asset(
                      'images/icon.png',
                      height: height * 0.5,
                    ),
                  ),
                  builder: (BuildContext context, Widget child) {
                    return Transform.rotate(
                      angle: _controller.value * 2.0 * pi,
                      child: child,
                    );
                  },
                ),
              ),
              SizedBox(
                height: height * 0.07,
              ),
              Center(
                child: Container(
                  width: 140,
                  height: 59,
                  child: ActionButton(
                    buttonTitle: 'New Game',
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrepareGrid(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
