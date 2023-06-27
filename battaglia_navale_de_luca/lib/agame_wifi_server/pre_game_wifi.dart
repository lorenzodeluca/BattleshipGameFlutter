import 'package:battaglia_navale_de_luca/agame_wifi_server/game_activity_wifi.dart';
import 'package:battaglia_navale_de_luca/prepare_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:battaglia_navale_de_luca/components/action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreGameWifi extends StatefulWidget {
  @override
  _PreGameWifiState createState() => _PreGameWifiState();
}

class _PreGameWifiState extends State<PreGameWifi> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Text(
                  'SEA BATTLE - WIFI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 55.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'username:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (data) async {
                          final SharedPreferences prefs = await _prefs;
                          prefs.setString("username", data);
                        },
                        style:
                            TextStyle(fontSize: 35, color: Colors.greenAccent),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter a username'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.all(1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'play against:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (data) async {
                          final SharedPreferences prefs = await _prefs;
                          prefs.setString("against", data);
                        },
                        style:
                            TextStyle(fontSize: 35, color: Colors.greenAccent),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter a username'),
                      ),
                    ),
                  ],
                ),
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
                  buttonTitle: 'connect',
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameActivityWifi(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
