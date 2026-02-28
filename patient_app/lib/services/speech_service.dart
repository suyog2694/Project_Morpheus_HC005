import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  late stt.SpeechToText _speech;
  bool _isInitialized = false;

  Future<void> init() async {
    _speech = stt.SpeechToText();
    _isInitialized = await _speech.initialize();
  }

  Future<void> startListening({
    required String localeId,
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) return;

    await _speech.listen(
      localeId: localeId,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  void stopListening() {
    _speech.stop();
  }
}