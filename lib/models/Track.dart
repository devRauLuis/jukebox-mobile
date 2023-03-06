class Track {
  final String? id;
  final String songName;
  final String? title;
  final String? trackNumber;
  final String? genre;
  final String? artist;
  final String? releaseTime;
  final String? year;
  final String? album;
  final String? image;
  final String? posId;

  Track(
      {required this.songName,
      this.id,
      this.title,
      this.trackNumber,
      this.genre,
      this.artist,
      this.releaseTime,
      this.year,
      this.album,
      this.image,
      this.posId});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
        id: json['id'],
        songName: json['songName'],
        title: json['title'],
        trackNumber: json['trackNumber'],
        genre: json['genre'],
        artist: json['artist'],
        releaseTime: json['releaseTime'],
        year: json['year'],
        album: json['album'],
        image: json['image'],
        posId: json["posId"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'songName': songName,
      'title': title,
      'trackNumber': trackNumber,
      'genre': genre,
      'artist': artist,
      'releaseTime': releaseTime,
      'year': year,
      'album': album,
      'image': image,
      "posId": posId
    };
  }
}
