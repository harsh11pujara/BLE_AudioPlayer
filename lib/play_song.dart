import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaySong extends StatefulWidget {
  const PlaySong({Key? key, required this.song}) : super(key: key);
  final SongModel song;

  @override
  State<PlaySong> createState() => _PlaySongState();
}

class _PlaySongState extends State<PlaySong> {
  final AudioPlayer player = AudioPlayer();
  final AudioCache audioCache = AudioCache();
  bool isPlaying = false;
  String songUrl = "";
  String songName = '';
  Duration? duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    // audioPlayerInit();
    super.initState();
  }

  // audioPlayerInit() async {
  //   String temp = widget.song.uri!.substring(10);
  //   int length = temp.length;
  //
  //   String temp2 = temp.substring(0,length-6);
  //   print(temp2);
  //   String temp3 = temp2+widget.song.title.toString();
  //   print(temp3);
  //   String finalUri = "file://$temp3";
  //   print(finalUri);
  //   File file = File(finalUri);
  //   // print(file.path);
  //   await player.setSourceUrl(finalUri);
  //   setState(() {
  //     // duration = player.duration!;
  //   });
  // }

  pickSong() async {
    FilePickerResult? song = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (song != null) {
      var temp = song.files[0];
      songUrl = "file://${temp.path}";
      songName = songUrl.split("/").last;
      await player.setSourceUrl(songUrl);
      duration = await player.getDuration();
      setState(() {});
    }
  }

  @override
  void dispose() {
    clearPlayer();
    super.dispose();
  }

  clearPlayer() async {
    await player.dispose();
    await audioCache.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.only(bottom: 30),
          height: 80,
          width: 250,
          child: IconButton(
              onPressed: () async {
                pickSong();
                // var t = await getTemporaryDirectory();
              },
              icon: const Icon(Icons.sd_storage_sharp)),
        ),
        SizedBox(
            height: 250,
            width: 250,
            child: Image.network("https://img.freepik.com/free-psd/music-poster-design-template_23-2149081201.jpg?w=2000")),
        const SizedBox(
          height: 20,
        ),
        songName != ''
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  songName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ))
            : Container(),
        const SizedBox(
          height: 25,
        ),
        SizedBox(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: (songUrl != "")
              ? StreamBuilder(
                  stream: player.onPositionChanged,
                  builder: (context, snapshot) {
                    Duration time = snapshot.data != null ? snapshot.data! : Duration.zero;
                    if (time.inSeconds == duration!.inSeconds) {
                      player.seek(Duration.zero).then((value) async {
                        await player.pause();
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
                              max: duration!.inSeconds.toDouble()),
                        ),
                        SizedBox(
                          width: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(formateTime(time)), Text(formateTime(duration!))],
                          ),
                        ),
                      ],
                    );
                  },
                )
              : const Center(child: Text("Select a song to Play")),
        ),
        const SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: () async {
            if (songUrl != "") {
              setState(() {
                isPlaying = !isPlaying;
              });
              if (isPlaying) {
                await player.play(UrlSource(songUrl));
              } else {
                await player.pause();
              }
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

  String formateTime(Duration time) {
    String min = time.inMinutes.toString().padLeft(2, "0");
    var temp = time.inMinutes > 0 ? time.inSeconds.remainder(60) : time.inSeconds;
    String sec = temp.toString().padLeft(2, "0");
    return "$min:$sec";
  }
}
