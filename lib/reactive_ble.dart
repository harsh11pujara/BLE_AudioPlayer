import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class ReactiveBLE extends StatefulWidget {
  const ReactiveBLE({Key? key}) : super(key: key);

  @override
  State<ReactiveBLE> createState() => _ReactiveBLEState();
}

class _ReactiveBLEState extends State<ReactiveBLE> {
  bool permissionGranted = false;
  FlutterReactiveBle reactiveBle = FlutterReactiveBle();

  void checkPermissions() async {
    print("true");
    var status = await Permission.location.request();
    var blue = await Permission.bluetooth.request();
    var blueStatusConnection = await Permission.bluetoothConnect.request();
    var blueStatus = await Permission.bluetoothScan.request();
    setState(() {
      permissionGranted = true;
    });

    if (status.isGranted) {
      if (blueStatus.isGranted) {
        reactiveBle.scanForDevices(withServices: []).listen((event) {
          print("event" + event.toString());
        });
      }
    } else {
      print("disable");
    }
  }

  @override
  void initState() {
    // Start scanning
    checkPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bluetooth",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(elevation: 0),
              onPressed: () {
                checkPermissions();
              },
              child: const Text(
                "Scan",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ))
        ],
      ),
    );
  }
}
