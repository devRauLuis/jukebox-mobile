import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';

import '../models/Track.dart';
import '../utils/keys.dart';

Future<Track> fetchMetadata(String songName) async {
  print("fetch metadata called $songName");
  var encodedUrl = Uri.encodeFull("$baseUrl/tracks/$songName/meta");
  print("encoded url $encodedUrl ${Uri.parse(encodedUrl)}");
  final response = await http.get(Uri.parse(encodedUrl));
  print("fetch metadata response $response");
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var metadata = Track.fromJson(jsonDecode(response.body));
    print("metadata: $metadata");

    return metadata;
  } else {
    throw Exception('Failed to fetch items');
  }
}

class NowPlaying extends StatelessWidget {
  final List<Track> queue;

  const NowPlaying({Key? key, required this.queue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Track>(
        future: fetchMetadata(queue[0].songName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CupertinoActivityIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final track = snapshot.data!;
            final bytes = base64.decode(track.image!);
            return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        color: CupertinoColors.white),
                    child: Column(children: [
                      Container(
                          child: bytes != null
                              ? Image.memory(
                                  bytes,
                                  fit: BoxFit.fitWidth,
                                )
                              : const Icon(CupertinoIcons.music_note)),
                      Column(
                        children: [
                          SizedBox(
                              height: 30,
                              child: Marquee(
                                text: "${track.title} - ${track.artist}",
                                textDirection: TextDirection
                                    .rtl, // start scrolling when text overflows the right edge
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 30.0,
                                velocity: 80.0,
                                pauseAfterRound: const Duration(seconds: 3),
                                accelerationDuration:
                                    const Duration(milliseconds: 500),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    const Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              )),
                          Column(
                            children: const [
                              Padding(
                                  padding: EdgeInsets.only(top: 10.0),
                                  child: Text("Next in queue:",
                                      style: TextStyle(fontSize: 14.0))),
                            ],
                          )
                        ],
                      ),
                    ])));
          }
        });
  }
}

// class NowPlaying extends StatefulWidget {
//   const NowPlaying(
//       {super.key,
//       required this.queue,
//       required this.metadata,
//       required this.setMetadata});
//   final List<Track> queue;
//   final Track? metadata;
//   final void Function(Track) setMetadata;

//   @override
//   State<NowPlaying> createState() => _NowPlayingState();
// }

// class _NowPlayingState extends State<NowPlaying> {
//   late Future<Track> futureNowPlaying;
//   late String _currentSongName;

//   @override
//   void initState() {
//     super.initState();

//     _currentSongName =
//         widget.queue.isNotEmpty ? widget.queue.first.songName : "";
//     futureNowPlaying = fetchMetadata(_currentSongName);
//   }

//   @override
//   void didUpdateWidget(NowPlaying oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     var queue = widget.queue;
//     if (queue.isNotEmpty && queue.first.songName != _currentSongName) {
//       _currentSongName = widget.queue.first.songName;
//       futureNowPlaying = fetchMetadata(_currentSongName);
//     }
//   }

//   Future<Track> fetchMetadata(String songName) async {
//     final response =
//         await http.get(Uri.parse('$baseUrl/tracks/$songName/meta'));
//     if (response.statusCode == 200) {
//       // If the server did return a 200 OK response,
//       // then parse the JSON.
//       var metadata = Track.fromJson(jsonDecode(response.body));
//       print("metadata: $metadata");

//       return metadata;
//     } else {
//       // If the server did not return a 200 OK response,
//       // then throw an exception.
//       return Track(id: "", songName: "");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Track>(
//         future: futureNowPlaying,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final track = snapshot.data!;
//             if (track.image != null) {
//               final bytes = base64.decode(track.image!);

//               return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Container(
//                       decoration: BoxDecoration(
//                           border: Border.all(width: 1),
//                           color: CupertinoColors.white),
//                       child: Column(children: [
//                         Container(
//                             child: bytes != null
//                                 ? Image.memory(
//                                     bytes,
//                                     fit: BoxFit.fitWidth,
//                                   )
//                                 : const Icon(CupertinoIcons.music_note)),
//                         Column(
//                           children: [
//                             SizedBox(
//                                 height: 30,
//                                 child: Marquee(
//                                   text: "${track.title} - ${track.artist}",
//                                   textDirection: TextDirection
//                                       .rtl, // start scrolling when text overflows the right edge
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 24.0,
//                                   ),
//                                   scrollAxis: Axis.horizontal,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   blankSpace: 30.0,
//                                   velocity: 100.0,
//                                   pauseAfterRound: const Duration(seconds: 3),
//                                   accelerationDuration:
//                                       const Duration(milliseconds: 500),
//                                   accelerationCurve: Curves.linear,
//                                   decelerationDuration:
//                                       const Duration(milliseconds: 500),
//                                   decelerationCurve: Curves.easeOut,
//                                 )),
//                             Column(
//                               children: const [
//                                 Padding(
//                                     padding: EdgeInsets.only(top: 10.0),
//                                     child: Text("Next in queue:",
//                                         style: TextStyle(fontSize: 14.0))),
//                               ],
//                             )
//                           ],
//                         ),
//                       ])));
//             }
//           }
//           return CupertinoActivityIndicator();
//         });

//     return FutureBuilder<Track>(
//       future: futureNowPlaying,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final track = snapshot.data!;
//           // print("image ${track.image}");

// // Text("${snapshot.data!.title}");
//         } else if (snapshot.hasError) {
//           return Text('${snapshot.error}');
//         }

//         // By default, show a loading spinner.
//         return const CupertinoActivityIndicator();
//       },
//     );
//   }
  // }
// }
// class NowPlaying extends StatefulWidget {
//   const NowPlaying({super.key, required this.queue});
//   final List<Track> queue;

//   @override
//   State<NowPlaying> createState() => _NowPlayingState();
// }
// 
// class _NowPlayingState extends State<NowPlaying> {
//   late Future<Track> futureNowPlaying;
//   late String _currentSongName;

//   @override
//   void initState() {
//     super.initState();

//     // _currentSongName =
//     //     widget.queue.isNotEmpty ? widget.queue.first.songName : "";
//     // print("current song name $_currentSongName");
//     // futureNowPlaying = fetchMetadata(_currentSongName);
//   }

//   @override
//   void didUpdateWidget(NowPlaying oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     var queue = widget.queue;
//     print("queue in nowplaying ${queue[0].songName} $_currentSongName");
//     if (queue.isNotEmpty && queue.first.songName != _currentSongName) {
//       _currentSongName = widget.queue.first.songName;
//       futureNowPlaying = fetchMetadata(_currentSongName);
//     }
//   }

//   Future<Track> fetchMetadata(String songName) async {
//     final response =
//         await http.get(Uri.parse('$baseUrl/tracks/$songName/meta'));
//     if (response.statusCode == 200) {
//       // If the server did return a 200 OK response,
//       // then parse the JSON.

//       return Track.fromJson(jsonDecode(response.body));
//     } else {
//       // If the server did not return a 200 OK response,
//       // then throw an exception.
//       // throw Exception('Failed to fetch');
//       print("an error ocurred");
//       return Track(id: "", songName: "");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Track>(
//       future: futureNowPlaying,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final track = snapshot.data!;
//           // print("image ${track.image}");
//           final bytes =
//               track.image != null ? base64.decode(track.image!) : null;

//           return Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Container(
//                   decoration: BoxDecoration(
//                       border: Border.all(width: 1),
//                       color: CupertinoColors.white),
//                   child: Column(children: [
//                     Container(
//                         child: bytes != null
//                             ? Image.memory(
//                                 bytes,
//                                 fit: BoxFit.fitWidth,
//                               )
//                             : const Icon(CupertinoIcons.music_note)),
//                     Column(
//                       children: [
//                         SizedBox(
//                             height: 30,
//                             child: Marquee(
//                               text: "${track.title} - ${track.artist}",
//                               textDirection: TextDirection
//                                   .rtl, // start scrolling when text overflows the right edge
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 24.0,
//                               ),
//                               scrollAxis: Axis.horizontal,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               blankSpace: 30.0,
//                               velocity: 100.0,
//                               pauseAfterRound: const Duration(seconds: 3),
//                               // startPadding: 50.0,
//                               accelerationDuration:
//                                   const Duration(milliseconds: 500),
//                               accelerationCurve: Curves.linear,
//                               decelerationDuration:
//                                   const Duration(milliseconds: 500),
//                               decelerationCurve: Curves.easeOut,
//                             )),
//                         Column(
//                           children: const [
//                             Padding(
//                                 padding: EdgeInsets.only(top: 10.0),
//                                 child: Text("Next in queue:",
//                                     style: TextStyle(fontSize: 14.0))),
//                           ],
//                         )
//                       ],
//                     ),
//                   ])));

// // Text("${snapshot.data!.title}");
//         } else if (snapshot.hasError) {
//           return Text('${snapshot.error}');
//         }

//         // By default, show a loading spinner.
//         return const CupertinoActivityIndicator();
//       },
//     );
//   }
// }
