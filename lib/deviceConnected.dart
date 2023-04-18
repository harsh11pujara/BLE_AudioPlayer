import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceConnected extends StatefulWidget {
  const DeviceConnected({Key? key, required this.device}) : super(key: key);
final BluetoothDevice device;
  @override
  State<DeviceConnected> createState() => _DeviceConnectedState();
}

class _DeviceConnectedState extends State<DeviceConnected> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Device Connected",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        actions: [

          ElevatedButton(
              style: ElevatedButton.styleFrom(elevation: 0),
              onPressed: () {

              },
              child: const Text(
                "Disconnect",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ))
        ],
      ),
      body: Column(children: [
        ElevatedButton(onPressed: (){}, child: const Text("Send Data"))
      ]),
    );
  }
}
