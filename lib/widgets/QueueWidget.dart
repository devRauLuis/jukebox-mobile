import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/Track.dart';
import '../utils/keys.dart';

class QueueWidget extends StatefulWidget {
  const QueueWidget({
    Key? key,
    required this.queue,
    required this.setQueue,
    required this.tracks,
    required this.setTracks,
  }) : super(key: key);

  final List<Track> queue;
  final void Function(List<Track>) setQueue;
  final List<Track> tracks;
  final void Function(List<Track>) setTracks;

  @override
  _QueueWidgetState createState() => _QueueWidgetState();
}

class _QueueWidgetState extends State<QueueWidget> {
  // late Future<List<Track>> futureList;
  late IO.Socket socket;
  List<Track> filteredTracks = [];

  @override
  void initState() {
    super.initState();
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('connected');
    });

    socket.on('disconnect', (_) {
      print('disconnected');
    });

    socket.on('error', (data) {
      print('error: $data');
    });

    socket.on('queueUpdated', (queue) {
      var data = queue[0];
      try {
        final encoded = jsonEncode(data);
        final decoded = jsonDecode(encoded);
        final parsed = decoded.cast<Map<String, dynamic>>();
        final tracks =
            parsed.map<Track>((json) => Track.fromJson(json)).toList();
        print("encoded: $encoded");
        print("decoded: $decoded");
        print("tracks: $tracks");
        widget.setQueue(tracks);
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    });

    socket.connect();

    fetchTracks();
    // widget.setTracks(tracks);

    filteredTracks.addAll(widget.tracks);
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  Future<List<Track>> fetchTracks() async {
    final response =
        await http.get(Uri.parse('$baseUrl/tracks-queue/all-tracks'));
    if (response.statusCode == 200) {
      final dataListJson = jsonDecode(response.body) as List<dynamic>;
      final dataList =
          dataListJson.map((json) => Track.fromJson(json)).toList();
      widget.setTracks(dataList);
      return dataList;
    } else {
      throw Exception('Failed to load tracks');
    }
  }

  void addTrackToQueue(String songName) async {
    final url = Uri.parse('$baseUrl/tracks-queue');
    final payload = {'name': songName};
    final response = await http.post(url, body: json.encode(payload), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      print('Error: HTTP status code ${response.statusCode}');
      return;
    }

    print('Track added to queue');
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 50.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CupertinoTextField(
              placeholder: 'Search tracks...',
              onChanged: (String? val) => {
                setState(() {
                  filteredTracks = widget.tracks
                      .where((e) =>
                          e.title!.toLowerCase().contains(val!.toLowerCase()))
                      .toList();

                  // print(
                  // "filtered tracks ${filteredTracks.length} $filteredTracks");
                })
              },
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: ListView.builder(
                    itemCount: filteredTracks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final track = filteredTracks[index];
                      final image = track.image != null
                          ? base64.decode(track.image!)
                          : null;

                      return Row(
                        children: [
                          Expanded(
                            child: CupertinoListTile(
                              leading: image != null
                                  ? Image.memory(image)
                                  : const Icon(CupertinoIcons.music_note),
                              title: Text("${track.title}"),
                              subtitle:
                                  Text('${track.artist} - ${track.album}'),
                            ),
                          ),
                          CupertinoButton(
                            onPressed: () => addTrackToQueue(track.songName),
                            child: const Icon(CupertinoIcons.text_badge_plus),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  // return const CupertinoActivityIndicator();
}
