import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecorder extends StatefulWidget {
  final void Function(String filePath) onRecorded;

  const VoiceRecorder({super.key, required this.onRecorded});

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  late FlutterSoundRecorder _recorder;
  bool _isRecording = false;
  String? _recordPath;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _audioPlayer = AudioPlayer();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  void _startRecording() async {
    if (!_isRecording) {
      _recordPath = 'temporary_path';
      await _recorder.startRecorder(toFile: _recordPath);
      setState(() => _isRecording = true);
    }
  }

  void _stopRecording() async {
    if (_isRecording) {
      _recordPath = await _recorder.stopRecorder() ?? _recordPath;
      if (_recordPath != null) {
        setState(() => _isRecording = false);
        widget.onRecorded(_recordPath!);
      }
    }
  }

  void _playRecording() async {
    await _audioPlayer.play(DeviceFileSource(_recordPath!));
  }

  void _resetRecording() async {
    setState(() {
      _recordPath = null;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_recordPath == null || _recordPath?.isEmpty == true) {
      return InkWell(
        onTap: () => _startRecording(),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => _startRecording(),
                icon: const Icon(Icons.mic, color: Colors.white),
                label: Text("Start Recording",
                    style: const TextStyle().copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } else if (_isRecording) {
      return Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton.icon(
          onPressed: () => _stopRecording(),
          icon: const Icon(Icons.stop, color: Colors.white),
          label: Text("Stop Recording",
              style: const TextStyle().copyWith(color: Colors.white)),
        ),
      );
    }
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => _playRecording(),
            icon: const Icon(Icons.play_arrow, color: Colors.black54),
            label: Text("Play",
                style: const TextStyle().copyWith(color: Colors.black54)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: VerticalDivider(),
          ),
          TextButton.icon(
            onPressed: () => _resetRecording(),
            icon: const Icon(Icons.delete, color: Colors.black54),
            label: Text("Delete",
                style: const TextStyle().copyWith(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
