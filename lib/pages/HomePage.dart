import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_service_demo/pages/artists/ArtistsScreen.dart';
import 'package:flutter_audio_service_demo/pages/genre/GenreScreen.dart';
import 'package:flutter_audio_service_demo/pages/songs/SongsPage.dart';
import 'package:flutter_audio_service_demo/pages/albums/AlbumsScreen.dart';
import 'package:just_audio/just_audio.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AudioPlayer player;
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  late final songList;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    _init();
  }

  Future<void> _init() async {
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    // await session.configure(AudioSessionConfiguration.speech());
    // this.player = Provider.of<AudioPlayerProvider>(context).player;
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  // @override
  // void dispose() {
  //   // Release decoders and buffers back to the operating system making them
  //   // available for other apps to use.
  //   // player.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              titleSpacing: 10,
              floating: true,
              pinned: true,
              title: Text("Music"),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                controller: _tabController,
                labelColor: Theme.of(context).textTheme.bodyText1!.color,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  new Tab(text: "Artists"),
                  new Tab(text: "Albums"),
                  new Tab(text: "Songs"),
                  new Tab(text: "Playlists"),
                  new Tab(text: "Genre"),
                  new Tab(text: "Folders"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            ArtistListPage(),
            AlbumsPage(),
            SongListPage(),
            SongListPage(),
            GenrePage(),
            SongListPage(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
