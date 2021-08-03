import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_service_demo/pages/genre/GenreDetailScreen.dart';

class GenrePage extends StatefulWidget {
  GenrePage({Key? key}) : super(key: key);

  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  GenreSortType _genresSortTypeSelected = GenreSortType.DEFAULT;

  Future<List<GenreInfo>?> _fetchSongData() async {
    try {
      final songs =
          await audioQuery.getGenres(sortType: _genresSortTypeSelected);
      return songs;
    } catch (error) {
      print("error is $error");
    }
  }

  @override
  void initState() {
    // final pageManager = getIt<PageManager>();
    // pageManager.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchSongData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as List<GenreInfo>;
          return data.length > 0
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final genre = data[index];
                    return ListTile(
                      title: Text("${genre.name}"),
                      leading:  Container(child: Image.asset("assets/album.png", scale: 0.5,fit: BoxFit.contain,)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {},
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GenreDetailScreen(
                                      genreInfo: genre,
                                    )));
                      },
                    );
                  })
              : (Text("No albums"));
        } else {
          return CircularProgressIndicator(
            color: Colors.white,
          );
        }
      },
    );
  }
}
