import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<bool> playWord(String languageCode, String wordId) async {
    try {
      await _player.play(AssetSource('audio/$languageCode/$wordId.mp3'));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() => _player.dispose();
}
