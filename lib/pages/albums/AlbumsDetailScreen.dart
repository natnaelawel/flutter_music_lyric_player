import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_service_demo/page_manager.dart';
import 'package:flutter_audio_service_demo/services/service_locator.dart';
import 'package:flutter_audio_service_demo/widgets/SongListWidget.dart';

class AlbumsDetailScreen extends StatefulWidget {
  final AlbumInfo albumInfo;
  AlbumsDetailScreen({Key? key, required this.albumInfo}) : super(key: key);

  @override
  _AlbumsDetailScreenState createState() => _AlbumsDetailScreenState();
}

class _AlbumsDetailScreenState extends State<AlbumsDetailScreen> {
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
      appBar: AppBar(title: Text("${widget.albumInfo.title}"),),

      body: Container(
          child: FutureBuilder(
              future: pageManager.loadArtistSongList(widget.albumInfo.id),
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
