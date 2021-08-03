import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_service_demo/page_manager.dart';
import 'package:flutter_audio_service_demo/services/service_locator.dart';
import 'package:flutter_audio_service_demo/widgets/SongListWidget.dart';

class GenreDetailScreen extends StatefulWidget {
  final GenreInfo genreInfo;
  GenreDetailScreen({Key? key, required this.genreInfo}) : super(key: key);

  @override
  _GenreDetailScreenState createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  final pageManager = getIt<PageManager>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // await pageManager.loadArtistSongList(widget.artistInfo.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.genreInfo.name}"),),

      body: Container(
          child: FutureBuilder(
              future: pageManager.loadGenreSongList(widget.genreInfo.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SongListWidget(
                      songList: snapshot.data as List<MediaItem>);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
    );
  }
}
