import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class AllConnectedDevice extends StatefulWidget {
  const AllConnectedDevice({Key? key}) : super(key: key);

  @override
  State<AllConnectedDevice> createState() => _AllConnectedDeviceState();
}

class _AllConnectedDeviceState extends State<AllConnectedDevice> {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    flutterBlue.startScan(timeout: const Duration(seconds: 2));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          "Connected Devices",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      body: Center(
          child: RefreshIndicator(
            onRefresh: () => flutterBlue.startScan(timeout: const Duration(seconds: 4)),
            child: StreamBuilder(
                    ///connected device stream
              stream: Stream.periodic(Duration(seconds: 5)).asyncMap((event) => flutterBlue.connectedDevices),
              builder: (context, snapshot) {
                List<BluetoothDevice> devices = [];
                if (snapshot.data != null) {
                  print("snap data" + snapshot.data!.toString());
                  var t = snapshot.data!.map((e) {
                    print("connected device  "+ e.toString());
                    devices.add(e);
                    return e;
                  }).toList();


                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text("$index."),
                        title: Text(devices[index].name.toString()),
                        subtitle: Text(devices[index].id.toString()),
                        trailing: ElevatedButton(
                          onPressed: () {
                          },
                          child: const Text("Disconnect"),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("No Device Connected"),
                  );
                }
              },
            ),
          ))

    );
  }
}
