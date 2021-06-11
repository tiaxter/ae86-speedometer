import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayChimeBackgroundTask extends BackgroundAudioTask {
  final AudioCache _player = new AudioCache(fixedPlayer: AudioPlayer());

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    await _player.loop('wav/chime.wav');
    super.onStart(params);
  }

  @override
  Future<void> onPlay() async {
    await _player.fixedPlayer?.resume();
    super.onPlay();
  }

  @override
  Future<void> onPause() async {
    await _player.fixedPlayer?.stop();
    super.onPause();
  }
}
