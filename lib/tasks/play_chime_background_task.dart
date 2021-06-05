import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audio_cache.dart';

class PlayChimeBackgroundTask extends BackgroundAudioTask {
  final AudioCache _player = new AudioCache();

  @override
  Future<void> onStart(Map<String, dynamic>? params) {
    AudioServiceBackground.setState(
        playing: true,
        processingState: AudioProcessingState.ready);
    _player.loop('wav/chime.wav');
    return super.onStart(params);
  }

  @override
  Future<void> onPause() async {
    await _player.fixedPlayer!.stop();
  }
}
