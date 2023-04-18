import 'package:audioplayers/audioplayers.dart';
import 'package:ble_audioplayer/allConnectedDevice.dart';
import 'package:ble_audioplayer/deviceConnected.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'reactive_ble.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // home: ReactiveBLE()
    home: StreamBuilder<BluetoothState>(
      stream: FlutterBlue.instance.state,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          BluetoothState state = snapshot.data!;
          if (state == BluetoothState.on) {
            return const MyApp();
          } else {
            return const BluetoothOff();
          }
        } else {
          return const BluetoothOff();
        }
      },
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  final AudioPlayer player = AudioPlayer();
  List<BluetoothDevice> connected = [];
  bool permissionGranted = false;
  bool audioPlayer = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  void checkPermissions() async {
    print("true");
    var status = await Permission.location.request();
    var blue = await Permission.bluetooth.request();
    var blueStatusConnection = await Permission.bluetoothConnect.request();
    var blueStatus = await Permission.bluetoothScan.request();
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    setState(() {
      permissionGranted = true;
    });

    if (status.isGranted) {
      if (blueStatus.isGranted) {
        // await flutterBlue.startScan(timeout: const Duration(seconds: 4), scanMode: ScanMode.lowLatency);
        // var subscription = flutterBlue.scanResults.listen((results) {
        //   print(results);
        //   for (ScanResult r in results) {
        //     print('${r.device.name} found! rssi: ${r.rssi}');
        //     if (!devices.contains(r.device)) {
        //       if (mounted) {
        //         setState(() {
        //           devices.add(r.device);
        //         });
        //       }
        //     }
        //   }
        //   // print("here");
        // });
        // flutterBlue.stopScan();
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
        title: Text(
          audioPlayer ? "Audio Player" : "Bluetooth",
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
        actions: [
          audioPlayer
              ? Container()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(elevation: 0),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllConnectedDevice(),
                        ));
                  },
                  child: const Text(
                    "Connected Device",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ))
        ],
      ),
      body: audioPlayer == false
          ? (permissionGranted == true
              ? Center(
                  child: RefreshIndicator(
                  onRefresh: () => flutterBlue.startScan(timeout: const Duration(seconds: 4)),
                  child: StreamBuilder(
                    /// Scan result
                    stream: flutterBlue.scanResults,

                    ///connected device stream
                    // stream: Stream.periodic(Duration(seconds: 5)).asyncMap((event) => flutterBlue.connectedDevices),
                    builder: (context, snapshot) {
                      List<BluetoothDevice> devices = [];
                      List temp = [];
                      if (snapshot.data != null) {
                        // print("snap data" + snapshot.data!.toString());
                        // var t = snapshot.data!.map((e) {
                        //   print("connected device  "+ e.toString());
                        //   devices.add(e);
                        //   return e;
                        // }).toList();
                        var t = snapshot.data!.map((e) {
                          // scan result process
                          // print("d " + e.device.toString());
                          devices.add(e.device);
                          return e.device;
                        }).toList();

                        // print("devices  " + t.toString());
                        return ListView.builder(
                          itemCount: devices.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Text("$index."),
                              title: Text(devices[index].name.toString()),
                              subtitle: Text(devices[index].id.toString()),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  connectToDevice(devices[index]);
                                },
                                child: const Text("Connect"),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("Data Not Found"),
                        );
                      }
                    },
                  ),
                ))
              : const Center(
                  child: Text("Permission Not Granted"),
                ))
          : audioPlayerPage(),
      drawer: Drawer(
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: [
                ListTile(
                  tileColor: Colors.blue,
                  title: Text(audioPlayer ? "Bluetooth" : "Audio Player",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      )),
                  onTap: () {
                    setState(() {
                      audioPlayer = !audioPlayer;
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            ),
          )),
    );
  }

  Widget audioPlayerPage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            height: 250,
            width: 250,
            child: Image.network("https://img.freepik.com/free-psd/music-poster-design-template_23-2149081201.jpg?w=2000")),
        const SizedBox(
          height: 20,
        ),
        const Text("Song Name"),
        const SizedBox(
          height: 35,
        ),
        SizedBox(
          width: 250,
          child: Slider(onChanged: (value) {}, value: 0),
        ),
        SizedBox(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text("00:00"), Text("05:00")],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: () async{
            if(isPlaying){
              // await player.play(Source);
            }else{
              player.pause();
            }
          },
          child: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Icon(Icons.play_arrow,color: Colors.white,),
          ),
        )
      ]),
    );
  }

  connectToDevice(BluetoothDevice device) async {
    await device.connect().whenComplete(() async {
      print("connected to " + device.name.toString());
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceConnected(device: device),
          ));
    });
  }
}

class BluetoothOff extends StatelessWidget {
  const BluetoothOff({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Icon(
          Icons.bluetooth_disabled,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
