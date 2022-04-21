import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SoundClick extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const SoundClick({Key? key, required this.onTap, required this.child})
      : super(key: key);

  @override
  State<SoundClick> createState() => _SoundClickState();
}

class _SoundClickState extends State<SoundClick> {
  late final AudioCache _audioCache;

  _playSound() {
    _audioCache.play('facebookchat.mp3');
  }

  @override
  void initState() {
    super.initState();
    _audioCache = AudioCache(
      prefix: 'audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap!();
        _playSound();
      },
      child: widget.child,
    );
  }
}
