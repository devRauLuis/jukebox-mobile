import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';

import '../models/Track.dart';
import '../utils/keys.dart';

class NowPlaying extends StatelessWidget {
  final List<Track> queue;

  const NowPlaying({Key? key, required this.queue}) : super(key: key);

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
                child: Stack(children: [
                  Container(
                    child: bytes != null
                        ? Image.memory(
                            bytes,
                            fit: BoxFit.fitWidth,
                          )
                        : const Icon(CupertinoIcons.music_note),
                  ),
                  Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color.fromARGB(0, 0, 0, 0),
                            CupertinoColors.black.withOpacity(0.5)
                          ],
                        ),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, right: 40.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                    padding: EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      "Now playing:",
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 14.0,
                                      ),
                                    )),
                                Text(
                                  "${track.title}",
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                Text(
                                  "${track.artist}",
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  "${track.album}",
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                if (queue.length > 1)
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10.0, top: 20.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Next in queue",
                                              style: TextStyle(
                                                color: CupertinoColors.white,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            Text(
                                              "${queue[1].title} - ${queue[1].artist}",
                                              style: const TextStyle(
                                                color: CupertinoColors.white,
                                                fontSize: 10.0,
                                              ),
                                            ),
                                          ])),
                              ])))
                ]));
          }
        });
  }
}
