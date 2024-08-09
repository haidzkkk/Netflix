
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayer extends StatefulWidget {
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final _player = AudioPlayer(

  );

  @override
  void initState() {
    super.initState();
    _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
  }

  void _playMusic() {
    _player.play();
  }

  void _pauseMusic() {
    _player.pause();
  }

  void _stopMusic() {
    _player.stop();
  }

  @override
  void dispose() {
    _player.dispose();
    textCtrl.dispose();
    super.dispose();
  }

  TextEditingController textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _playMusic,
            child: Text('Play Music'),
          ),
          ElevatedButton(
            onPressed: _pauseMusic,
            child: Text('Pause Music'),
          ),
          ElevatedButton(
            onPressed: _stopMusic,
            child: Text('Stop Music'),
          ),
        ],
      ),
    );
  }
}