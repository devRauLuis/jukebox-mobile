import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/Track.dart';
import '../utils/keys.dart';

Future<List<Track>> fetchTracks() async {
  final response =
      await http.get(Uri.parse('$baseUrl/tracks-queue/all-tracks'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    final dataListJson = jsonDecode(response.body) as List<dynamic>;
    final dataList = dataListJson.map((json) => Track.fromJson(json)).toList();
    return dataList;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load tracks');
  }
}

class TrackList extends StatefulWidget {
  const TrackList({Key? key}) : super(key: key);

  @override
  State<TrackList> createState() => _TrackListState();
}

class _TrackListState extends State<TrackList> {
  late Future<List<Track>> futureList;

  @override
  void initState() {
    super.initState();
    futureList = fetchTracks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Track>>(
        future: futureList,
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                height: 200.0,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data![index];

                    return Column(
                      children: [
                        CupertinoListTile(
                          title: Text("${data.title}"),
                          subtitle: Text("${data.artist}"),
                          onTap: () {
                            // Do something when the list tile is tapped
                          },
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: CupertinoButton(
                            child: Text("Add to Queue"),
                            onPressed: () {
                              // Do something when the button is pressed
                            },
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ],
                    );
                  },
                ));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return Text("Loading");
          // return const CircularProgressIndicator();
        }));
  }
}
