import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_service_demo/page_manager.dart';
import 'package:flutter_audio_service_demo/pages/player/PlayerPage.dart';
import 'package:flutter_audio_service_demo/services/service_locator.dart';
import 'package:flutter_audio_service_demo/widgets/SongListWidget.dart';

class SongListPage extends StatefulWidget {
  SongListPage({Key? key, required}) : super(key: key);

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  @override
  void initState() {
    final pageManager = getIt<PageManager>();
    // pageManager.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SongList();

    // return FutureBuilder(
    //   future: Provider.of<AudioRepository>(context).fetchSongData(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       final data = snapshot.data as List<SongInfo>;
    //       print("the number of songs are ${data.length}");
    //       return SongListWidget(songList: data, player: widget.player);
    //     } else {
    //       return CircularProgressIndicator();
    //     }
    //   },
    // );
  }
}

class SongList extends StatelessWidget {
  const SongList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Expanded(
      child: ValueListenableBuilder<List<MediaItem>>(
        valueListenable: pageManager.songListNotifier,
        builder: (context, songs, _) {
          print("${songs.length} song are there");
          return SongListWidget(songList: songs);
          // return ListView.builder(
          //   itemCount: songs.length,
          //   itemBuilder: (context, index) {
          //     final song = songs[index];
          //     return ListTile(
          //       title: Text('${song.title}'),
          //       onTap: () async {
          //         await pageManager.playMediaItem(song).then((value) => value);
          //         Navigator.of(context).push(
          //             MaterialPageRoute(builder: (context) => PlayerPage()));
          //       },
          //     );
          //   },
          // );
        },
      ),
    );
  }
}
