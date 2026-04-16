import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceCommandService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<String?> startListening() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception('Microphone permission denied');
    }

    if (_isListening) {
      return null;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (error) {
        _isListening = false;
      },
    );

    if (!available) {
      throw Exception('Speech recognition not available');
    }

    String? result;

    _isListening = true;
    await _speech.listen(
      onResult: (val) {
        if (val.finalResult) {
          result = val.recognizedWords;
          _isListening = false;
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );

    // Wait for result or timeout
    int attempts = 0;
    while (_isListening && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }

    return result;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  bool get isListening => _isListening;

  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }
}

