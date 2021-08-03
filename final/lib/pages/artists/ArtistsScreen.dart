import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_service_demo/pages/artists/ArtistsDetailScreen.dart';
import 'package:flutter_audio_service_demo/widgets/ListWidget.dart';

class ArtistListPage extends StatefulWidget {
  ArtistListPage({Key? key}) : super(key: key);

  @override
  _ArtistListPageState createState() => _ArtistListPageState();
}

class _ArtistListPageState extends State<ArtistListPage> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  ArtistSortType _artistSortTypeSelected = ArtistSortType.DEFAULT;

  Future<List<ArtistInfo>?> _fetchSongData() async {
    try {
      final songs =
          await audioQuery.getArtists(sortType: _artistSortTypeSelected);

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
          final data = snapshot.data as List<ArtistInfo>;
          return data.length > 0
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final artist = data[index];
                    return ListItemWidget(
                      selected: false,
                      title: Text("${artist.name}"),
                      imagePath: artist.artistArtPath,
                      subtitle: Column(
                        children: [
                          Text(
                            "Albums: ${artist.numberOfAlbums}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            "Tracks: ${artist.numberOfTracks}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {},
                      ),
                      leading: SizedBox.shrink(),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ArtistsDetailScreen(
                                      artistInfo: artist,
                                    )));
                      },
                    );
                  })
              : (Text("No Artists"));
        } else {
          return CircularProgressIndicator(
            color: Colors.white,
          );
        }
      },
    );
  }
}
