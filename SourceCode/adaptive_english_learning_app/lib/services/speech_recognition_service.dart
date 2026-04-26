import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionService {
  SpeechRecognitionService({SpeechToText? speechToText})
    : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;

  bool get isListening => _speechToText.isListening;

  Future<bool> initialize() {
    return _speechToText.initialize();
  }

  Future<void> startListening({
    required void Function(String transcript) onResult,
  }) async {
    final available = await _speechToText.initialize();
    if (!available) {
      throw Exception('Speech recognition is unavailable on this device.');
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stopListening() {
    return _speechToText.stop();
  }
}
