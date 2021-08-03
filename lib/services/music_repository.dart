import 'package:flutter_audio_query/flutter_audio_query.dart';

abstract class MusicListRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSong();

  Future<List<SongInfo>> fetchSongs();
  Future<List<SongInfo>> fetchArtistSongs(String id);
  Future<List<SongInfo>> fetchAlbumSongs(String id);
  Future<List<SongInfo>> fetchGenreSongs(String id);
  Future<List<ArtistInfo>> fetchArtists();
  Future<List<AlbumInfo>> fetchAlbums();
  Future<List<GenreInfo>> fetchGenres();
}

class SongRepository extends MusicListRepository {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  ArtistSortType _artistSortTypeSelected = ArtistSortType.DEFAULT;
  AlbumSortType _albumSortTypeSelected = AlbumSortType.DEFAULT;
  SongSortType _songSortTypeSelected = SongSortType.DEFAULT;
  GenreSortType _genreSortTypeSelected = GenreSortType.DEFAULT;

  @override
  Future<List<SongInfo>> fetchSongs() async {
    final songs = await audioQuery.getSongs(sortType: _songSortTypeSelected);
    return songs;
  }

  @override
  Future<List<SongInfo>> fetchArtistSongs(String artistId) async {
    final songs = await audioQuery.getSongsFromArtist(artistId: artistId);
    return songs;
  }

  @override
  Future<List<SongInfo>> fetchAlbumSongs(String albumId) async {
    final songs = await audioQuery.getSongsFromAlbum(albumId: albumId);
    return songs;
  }

  @override
  Future<List<SongInfo>> fetchGenreSongs(String genreId) async {
    final songs = await audioQuery.getSongsFromGenre(genre: genreId);
    return songs;
  }

  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = 3}) async {
    return List.generate(length, (index) => _nextSong());
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  var _songIndex = 0;
  static const _maxSongNumber = 16;

  Map<String, String> _nextSong() {
    _songIndex = (_songIndex % _maxSongNumber) + 1;
    return {
      'id': _songIndex.toString().padLeft(3, '0'),
      'title': 'Song $_songIndex',
      'album': 'SoundHelix',
      'url':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$_songIndex.mp3',
    };
  }

  @override
  Future<List<ArtistInfo>> fetchArtists() async {
    final songs =
        await audioQuery.getArtists(sortType: _artistSortTypeSelected);
    return songs;
  }

  @override
  Future<List<AlbumInfo>> fetchAlbums() async {
    final songs = await audioQuery.getAlbums(sortType: _albumSortTypeSelected);
    return songs;
  }

  @override
  Future<List<GenreInfo>> fetchGenres() async {
    final songs = await audioQuery.getGenres(sortType: _genreSortTypeSelected);
    return songs;
  }
}
// @override
// Future<List<SongInfo>?> fetchSongList() async {
//   try {
//     final songs = await audioQuery.getSongs(sortType: _songSortTypeSelected);
//     return songs;
//   } catch (error) {
//     print("error is $error");
//     return null;
//   }
// }
