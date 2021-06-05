import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayChimeBackgroundTask extends BackgroundAudioTask {
  final _player = AudioPlayer();

  onPlay() => _player.play();
  onPause() => _player.pause();
}