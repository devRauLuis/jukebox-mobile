// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// import '../models/Track.dart';
// import '../utils/keys.dart';

// class QueueWidget extends StatefulWidget {
//   const QueueWidget({Key? key}) : super(key: key);

//   @override
//   _QueueWidgetState createState() => _QueueWidgetState();
// }

// class _QueueWidgetState extends State<QueueWidget> {
//   late Future<List<Track>> futureList;
//   late IO.Socket socket;

//   @override
//   void initState() {
//     super.initState();
//     socket = IO.io('http://localhost:3000', <String, dynamic>{
//       'transports': ['websocket'],
//     });
//     socket.on('queueUpdated', (queue) {
//       final List<Track> tracks =
//           (queue as List<dynamic>).map((json) => Track.fromJson(json)).toList();
//       setState(() {
//         futureList = Future.value(tracks);
//       });
//     });
//     futureList = fetchTracks();
//   }

//   @override
//   void dispose() {
//     socket.dispose();
//     super.dispose();
//   }

//   Future<List<Track>> fetchTracks() async {
//     final response = await http.get(Uri.parse('$baseUrl/tracks-queue'));
//     if (response.statusCode == 200) {
//       final dataListJson = jsonDecode(response.body) as List<dynamic>;
//       final dataList =
//           dataListJson.map((json) => Track.fromJson(json)).toList();
//       return dataList;
//     } else {
//       throw Exception('Failed to load tracks');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Track>>(
//         future: futureList,
//         builder: ((context, snapshot) {
//           if (snapshot.hasData) {
//             final tracks = snapshot.data!;
//             return ListView.builder(
//                 itemCount: tracks.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   final track = tracks[index];
//                   final image =
//                       track.image != null ? base64.decode(track.image!) : null;

//                   return CupertinoListTile(
//                     leading: image != null
//                         ? Image.memory(image)
//                         : const Icon(CupertinoIcons.music_note),
//                     title: Text("${track.title}"),
//                     subtitle: Text('${track.artist} - ${track.album}'),
//                   );
//                 });
//           }

//           return const CupertinoActivityIndicator();
//         }));
//   }
// }

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/Track.dart';
import '../utils/keys.dart';

class QueueWidget extends StatefulWidget {
  const QueueWidget({Key? key, required this.queue, required this.setQueue})
      : super(key: key);

  final List<Track> queue;
  final void Function(List<Track>) setQueue;

  @override
  _QueueWidgetState createState() => _QueueWidgetState();
}

class _QueueWidgetState extends State<QueueWidget> {
  // late Future<List<Track>> futureList;
  late IO.Socket socket;

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
    // var tracks = fetchTracks();
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
      return dataList;
    } else {
      throw Exception('Failed to load tracks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = widget.queue;

    return ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (BuildContext context, int index) {
          final track = tracks[index];
          final image =
              track.image != null ? base64.decode(track.image!) : null;

          return CupertinoListTile(
            leading: image != null
                ? Image.memory(image)
                : const Icon(CupertinoIcons.music_note),
            title: Text("${track.title}"),
            subtitle: Text('${track.artist} - ${track.album}'),
          );
        });
  }

  // return const CupertinoActivityIndicator();
}
