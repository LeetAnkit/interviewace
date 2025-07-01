import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;

  // Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  // Start recording
  Future<bool> startRecording() async {
    try {
      if (!await requestPermission()) {
        throw Exception('Microphone permission denied');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      _currentRecordingPath = '${directory.path}/$fileName';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 128000,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      return true;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  // Stop recording
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  // Play audio file
  Future<void> playAudio(String filePath) async {
    try {
      await _player.play(DeviceFileSource(filePath));
      _isPlaying = true;

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      throw Exception('Failed to play audio: $e');
    }
  }

  // Stop audio playback
  Future<void> stopAudio() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      throw Exception('Failed to stop audio: $e');
    }
  }

  // Pause audio playback
  Future<void> pauseAudio() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      throw Exception('Failed to pause audio: $e');
    }
  }

  // Resume audio playback
  Future<void> resumeAudio() async {
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      throw Exception('Failed to resume audio: $e');
    }
  }

  // Get audio duration
  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      await _player.setSource(DeviceFileSource(filePath));
      return await _player.getDuration();
    } catch (e) {
      return null;
    }
  }

  // Dispose resources
  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
