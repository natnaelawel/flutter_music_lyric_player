import 'package:audio_service/audio_service.dart';
import 'package:flutter_audio_service_demo/services/music_repository.dart';

import '../page_manager.dart';
import 'audio_handler.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  getIt.registerLazySingleton<MusicListRepository>(() => SongRepository());

  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}
