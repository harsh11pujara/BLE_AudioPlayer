import 'dart:io';

import 'package:ble_audioplayer/allConnectedDevice.dart';
import 'package:ble_audioplayer/deviceConnected.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final player = AudioPlayer();
  List<BluetoothDevice> connected = [];
  bool permissionGranted = false;
  bool audioPlayer = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String assetSong = "assets/Maan Meri Jaan.mp3";
  String? localSong;

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
    audioPlayerInit();
    super.initState();
  }

  audioPlayerInit() async {
    await player.setAsset(assetSong);
    duration = player.duration!;
  }

  void audioPlayerLocalSongInit() async {
    await player.setAudioSource(AudioSource.uri(Uri.parse(localSong!)));
    await player.load();
    duration = player.duration!;
  }

  pickSong() async {
    FilePickerResult? song = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (song != null) {
      // await player.dispose();
      var temp = song.files[0];
      print(temp.path);

      File temp1 = File("asset://${temp.path}");
      var url = Uri.parse("asset://${temp.path}");
      setState(() {
        localSong = "asset:///${temp.path}";
        // localSong = temp.path!;
        audioPlayerLocalSongInit();
      });
    }
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
        Container(
          padding: EdgeInsets.only(bottom: 30),
          height: 80,
          width: 250,
          child: IconButton(
              onPressed: () async{
                pickSong();
                // var t = await getTemporaryDirectory();
              },
              icon: Icon(Icons.sd_storage_sharp)),
        ),
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
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder(
            stream: player.positionStream,
            builder: (context, snapshot) {
              Duration time = snapshot.data != null ? snapshot.data! : Duration.zero;
              if (time.inSeconds == duration.inSeconds) {
                player.stop().then((value) {
                  if (mounted) {
                    setState(() {
                      isPlaying = false;
                    });
                  }
                });
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 250,
                    child: Slider(
                        onChanged: (value) {
                          setState(() {
                            player.seek(Duration(seconds: value.toInt()));
                          });
                        },
                        value: time.inSeconds.toDouble(),
                        min: 0,
                        max: duration.inSeconds.toDouble()),
                  ),
                  SizedBox(
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(formateTime(time)), Text(formateTime(duration))],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: () async {
            setState(() {
              isPlaying = !isPlaying;
            });
            if (isPlaying) {
              await player.play();
            } else {
              await player.pause();
            }
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
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

  String formateTime(Duration time) {
    String min = time.inMinutes.toString().padLeft(2, "0");
    var temp = time.inMinutes > 0 ? time.inSeconds.remainder(60) : time.inSeconds;
    String sec = temp.toString().padLeft(2, "0");
    return "$min:$sec";
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
