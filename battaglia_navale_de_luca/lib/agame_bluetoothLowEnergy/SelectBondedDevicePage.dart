import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';


class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelectBondedDevicePage({this.checkAvailability = true});

  @override
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}



/* class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
} */

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  //List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();
  List<BluetoothDevice> devices = List();

  // Availability
  //StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  StreamSubscription<List<ScanResult>> subscription;
  bool _isDiscovering=true;

  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = true;

    if (_isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    //flutter blue
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    subscription = flutterBlue.scanResults.listen((scanResult) {
      // do something with scan result
      print("FANCULOOOOOOOOoooOOOOOooOOO flutter");
      scanResult.forEach((f) {
        if (!devices.contains(f.device)) {
          devices.add(f.device);
        }
      });
      //print('${device.name} found! rssi: ${scanResult.rssi}');
    });
    subscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
    /* _discoveryStreamSubscription.onDone(() {
    setState(() {
      _isDiscovering = false;
    });
  }); */
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
        appBar: AppBar(
          title: Text('Select device'),
          actions: <Widget>[
            (_isDiscovering
                ? FittedBox(
                    child: Container(
                        margin: new EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white))))
                : IconButton(
                    icon: Icon(Icons.replay), onPressed: _restartDiscovery))
          ],
        ),
        body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, position) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  devices.elementAt(position).name.toString(),
                  style: TextStyle(fontSize: 22.0),
                ),
              ),
            );
          },
        ));
  }
}
