import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_audio_service_demo/pages/albums/AlbumsDetailScreen.dart';
import 'package:flutter_audio_service_demo/widgets/ListWidget.dart';

class AlbumsPage extends StatefulWidget {
  AlbumsPage({Key? key}) : super(key: key);

  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  AlbumSortType _albumsSortTypeSelected = AlbumSortType.DEFAULT;

  Future<List<AlbumInfo>?> _fetchSongData() async {
    try {
      final songs =
          await audioQuery.getAlbums(sortType: _albumsSortTypeSelected);
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
          final data = snapshot.data as List<AlbumInfo>;
          return data.length > 0
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: data.length,
                  itemBuilder: (BuildContext ctx, index) {
                    final album = data[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AlbumsDetailScreen(
                                      albumInfo: album,
                                    )));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(album.title),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            image: DecorationImage(
                                image: (album.albumArt != null)
                                    ? FileImage(File(album.albumArt))
                                    : (AssetImage("assets/album.png")
                                        as ImageProvider<Object>)),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    );
                    // return ListItemWidget(
                    //   selected: false,
                    //   title: Text("${album.title}"),
                    //   imagePath: album.albumArt,
                    //   subtitle: Column(
                    //     children: [
                    //       Text(
                    //         "Artists: ${album.artist}",
                    //         overflow: TextOverflow.ellipsis,
                    //         maxLines: 1,
                    //       ),
                    //       Text(
                    //         "Songs: ${album.numberOfSongs}",
                    //         overflow: TextOverflow.ellipsis,
                    //         maxLines: 1,
                    //       ),
                    //     ],
                    //   ),
                    //   trailing: IconButton(
                    //     icon: Icon(Icons.delete),
                    //     onPressed: () {},
                    //   ),
                    //   leading: SizedBox.shrink(),
                    //   onTap: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => AlbumsDetailScreen(
                    //                   albumInfo: album,
                    //                 )));
                    //   },
                    // );
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
