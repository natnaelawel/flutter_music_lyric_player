import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/service_locator.dart';
import 'package:flutter_audio_service_demo/services/music_repository.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongNotifier =
      ValueNotifier<MediaItem>(MediaItem(id: "", title: ""));

  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final songListNotifier = ValueNotifier<List<MediaItem>>([]);
  final artistListNotifier = ValueNotifier<List<ArtistInfo>>([]);

  final _audioHandler = getIt<AudioHandler>();

  // Events: Calls coming from the UI
  void init() async {
    // await _loadPlaylist();
    await loadSongList();
    // _listenToChangesInPlaylist();
    _listenToChangesInSongList();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    final songRepository = getIt<MusicListRepository>();
    final playlist = await songRepository.fetchInitialPlaylist();
    final mediaItems = playlist
        .map((song) => MediaItem(
              id: song['id'] ?? '',
              album: song['album'] ?? '',
              title: song['title'] ?? '',
              extras: {'url': song['url']},
            ))
        .toList();
    _audioHandler.addQueueItems(mediaItems);
  }

  Future<void> loadSongList() async {
    final songRepository = getIt<MusicListRepository>();
    final songs = await songRepository.fetchSongs();
    final mediaItems = songs
        .map((song) => MediaItem(
            id: song.id,
            album: song.album,
            title: song.title,
            extras: {'url': song.uri},
            artist: song.artist,
            artUri: Uri(path: song.albumArtwork),
            displaySubtitle: song.displayName,
            duration: Duration(milliseconds: int.parse(song.duration))))
        .toList();
    _audioHandler.addQueueItems(mediaItems);
  }

  Future<List<MediaItem>> loadArtistSongList(String artistId) async {
    final songRepository = getIt<MusicListRepository>();
    final songs = await songRepository.fetchArtistSongs(artistId);
    final mediaItems = songs
        .map((song) => MediaItem(
            id: song.id,
            album: song.album,
            title: song.title,
            extras: {'url': song.uri},
            artist: song.artist,
            artUri: Uri(path: song.albumArtwork),
            displaySubtitle: song.displayName,
            duration: Duration(milliseconds: int.parse(song.duration))))
        .toList();

    if (_audioHandler.queue.value.length > 0) {
      _audioHandler.updateQueue(mediaItems);
    } else {
      _audioHandler.addQueueItems(mediaItems);
    }

    print("hello world ${mediaItems.length}");
    _listenToChangesInSongList();
    return mediaItems;
  }

  Future<List<MediaItem>> loadGenreSongList(String genreId) async {
    final songRepository = getIt<MusicListRepository>();
    final songs = await songRepository.fetchGenreSongs(genreId);
    final mediaItems = songs
        .map((song) => MediaItem(
            id: song.id,
            album: song.album,
            title: song.title,
            extras: {'url': song.uri},
            artist: song.artist,
            artUri: Uri(path: song.albumArtwork),
            displaySubtitle: song.displayName,
            duration: Duration(milliseconds: int.parse(song.duration))))
        .toList();

    if (_audioHandler.queue.value.length > 0) {
      _audioHandler.updateQueue(mediaItems);
    } else {
      _audioHandler.addQueueItems(mediaItems);
    }

    print("hello world ${mediaItems.length}");
    _listenToChangesInSongList();
    return mediaItems;
  }

  Future<List<MediaItem>> loadAlbumSongList(String albumId) async {
    final songRepository = getIt<MusicListRepository>();
    final songs = await songRepository.fetchAlbumSongs(albumId);
    final mediaItems = songs
        .map((song) => MediaItem(
            id: song.id,
            album: song.album,
            title: song.title,
            extras: {'url': song.uri},
            artist: song.artist,
            artUri: Uri(path: song.albumArtwork),
            displaySubtitle: song.displayName,
            duration: Duration(milliseconds: int.parse(song.duration))))
        .toList();
    print("hello world");
    if (_audioHandler.queue.value.length > 0) {
      _audioHandler.updateQueue(mediaItems);
    }
    _audioHandler.addQueueItems(mediaItems);

    _listenToChangesInSongList();

    return mediaItems;
  }

  void _listenToChangesInSongList() {
    _audioHandler.queue.listen((songs) {
      if (songs.isEmpty) {
        songListNotifier.value = [];
        currentSongTitleNotifier.value = '';
        currentSongNotifier.value = MediaItem(id: "", title: "");
      } else {
        final newList = songs.map((item) => item).toList();
        songListNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
        currentSongNotifier.value = MediaItem(id: "", title: "");

      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      currentSongNotifier.value = mediaItem ?? MediaItem(id: "id", title: "title");
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  Future<void> playMediaItem(MediaItem item) async {
    print("music id is ${item.id}");
    await _audioHandler.skipToQueueItem(await _audioHandler.queue.value
        .indexWhere((element) => element.id == item.id));
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add() async {
    final songRepository = getIt<MusicListRepository>();
    final song = await songRepository.fetchAnotherSong();
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}
