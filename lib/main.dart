import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/TracksState.dart';
import 'package:mobile/widgets/AccordionWidget.dart';
import 'package:mobile/widgets/Album.dart';
import 'package:mobile/widgets/NowPlaying.dart';
import 'package:mobile/widgets/QueueWidget.dart';
import 'package:mobile/widgets/TrackList.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TracksState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: "Jukebox",
      home: MyHomePage(),
      // theme: CupertinoThemeData(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Jukebox'),
      ),
      child: SafeArea(
        // child: Padding(
        // padding: const EdgeInsets.only(top: 20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(child:
                  Consumer<TracksState>(builder: (context, value, child) {
                if (value.queue.isNotEmpty) {
                  return NowPlaying(
                    queue: value.queue,
                  );
                } else {
                  return const CupertinoActivityIndicator();
                }
              })),
              Expanded(
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return SizedBox(
                    height:
                        constraints.maxHeight, // fetch height with Constraints
                    width: constraints.maxWidth,
                    child: Consumer<TracksState>(
                        builder: (context, value, child) => QueueWidget(
                              queue: value.queue,
                              setQueue: value.setQueue,
                            )),
                  );
                }),
              )
            ]),
      ),
    );
// );
  }
}
