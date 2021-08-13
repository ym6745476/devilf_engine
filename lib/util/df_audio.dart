import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';

/// 音效播放
class DFAudio {
  /// 音频类
  static AudioCache audioCache = AudioCache(prefix: 'assets/audio/');

  /// 计数
  int count = 0;

  /// 定时播放
  Timer? timer;

  /// 开始播放音效序列
  void startPlay(List<String> files, {stepTime = 400, loop = false}) {
    count = 0;
    timer = Timer.periodic(Duration(milliseconds: stepTime), (t) {
      if (count == files.length) {
        if (loop) {
          count = 0;
          String file = files.elementAt(count);
          play(file);
        } else {
          timer!.cancel();
          timer = null;
        }
      } else {
        String file = files.elementAt(count);
        play(file);
      }
      count++;
    });
  }

  /// 取消播放音效序列
  void stopPlay() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
      count = 0;
    }
  }

  /// 背景音乐
  static BackgroundMusic backgroundMusic = BackgroundMusic(audioCache: audioCache);

  /// 播放短音频
  static Future<AudioPlayer> play(String file, {double volume = 1.0}) {
    return audioCache.play(file, volume: volume, mode: PlayerMode.LOW_LATENCY);
  }

  /// 循环播放
  static Future<AudioPlayer> loop(String file, {double volume = 1.0}) {
    return audioCache.loop(file, volume: volume, mode: PlayerMode.LOW_LATENCY);
  }

  /// 播放长音频
  static Future<AudioPlayer> playLongAudio(String file, {double volume = 1.0}) {
    return audioCache.play(file, volume: volume);
  }

  /// 循环播放长音频
  static Future<AudioPlayer> loopLongAudio(String file, {double volume = 1.0}) {
    return audioCache.loop(file, volume: volume);
  }
}

/// 背景音乐
class BackgroundMusic extends WidgetsBindingObserver {
  bool _isRegistered = false;
  late AudioCache audioCache;
  AudioPlayer? audioPlayer;
  bool isPlaying = false;

  BackgroundMusic({AudioCache? audioCache}) : audioCache = audioCache ?? AudioCache();

  void initialize() {
    if (_isRegistered) {
      return;
    }
    _isRegistered = true;
    WidgetsBinding.instance?.addObserver(this);
  }

  Future<void> play(String filename, {double volume = 1}) async {
    final currentPlayer = audioPlayer;
    if (currentPlayer != null && currentPlayer.state != PlayerState.STOPPED) {
      currentPlayer.stop();
    }

    isPlaying = true;
    audioPlayer = await audioCache.loop(filename, volume: volume);
  }

  Future<Uri> load(String file) => audioCache.load(file);

  Future<File> loadAsFile(String file) => audioCache.loadAsFile(file);

  Future<List<Uri>> loadAll(List<String> files) => audioCache.loadAll(files);

  void clear(Uri file) => audioCache.clear(file);

  void clearAll() => audioCache.clearAll();

  Future<void> stop() async {
    isPlaying = false;
    if (audioPlayer != null) {
      await audioPlayer!.stop();
    }
  }

  Future<void> resume() async {
    if (audioPlayer != null) {
      isPlaying = true;
      await audioPlayer!.resume();
    }
  }

  Future<void> pause() async {
    if (audioPlayer != null) {
      isPlaying = false;
      await audioPlayer!.pause();
    }
  }

  void dispose() {
    if (!_isRegistered) {
      return;
    }
    WidgetsBinding.instance?.removeObserver(this);
    _isRegistered = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isPlaying && audioPlayer?.state == PlayerState.PAUSED) {
        audioPlayer?.resume();
      }
    } else {
      audioPlayer?.pause();
    }
  }
}
