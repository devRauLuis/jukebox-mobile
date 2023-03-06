import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:mobile/models/Track.dart';
import 'package:provider/provider.dart';

class TracksState extends ChangeNotifier {
  /// Internal, private state of the cart.
  final List<Track> _queue = [];
  final List<Track> _tracks = [];
  Track? _metadata;

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<Track> get queue => UnmodifiableListView(_queue);
  UnmodifiableListView<Track> get tracks => UnmodifiableListView(_tracks);
  Track? get metadata => _metadata;

  void setQueue(List<Track> newQueue) {
    _queue.clear();
    _queue.addAll(newQueue);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void setTracks(List<Track> newQueue) {
    _tracks.clear();
    _tracks.addAll(newQueue);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void setMetadata(Track newMetadata) {
    _metadata = newMetadata;
    notifyListeners();
  }
}
