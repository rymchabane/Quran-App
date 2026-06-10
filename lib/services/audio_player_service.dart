import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/surah_model.dart';
import '../models/reciter_model.dart';
import '../services/api_service.dart';
import 'notification_service.dart';
import 'stats_service.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  static final ValueNotifier<bool> isActiveNotifier = ValueNotifier(false);
  static final ValueNotifier<Surah?> currentSurahNotifier = ValueNotifier(null);
  static bool isPlayerPageOpen = false;

  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  late AudioPlayer _player = AudioPlayer();

  Surah? currentSurah; // THIS is what you had before
  Reciter? currentReciter;
  List<Surah> currentPlaylist = [];
  Map<int, Reciter> currentPlaylistReciters = {}; // add this — surahNumber -> Reciter

  AudioPlayer get player => _player;

  Surah? get nextSurah {
    if (currentSurah == null || currentPlaylist.isEmpty) return null;
    final idx = currentPlaylist.indexWhere((s) => s.number == currentSurah!.number);
    if (idx == -1 || idx == currentPlaylist.length - 1) return null;
    return currentPlaylist[idx + 1];
  }

  Surah? get previousSurah {
    if (currentSurah == null || currentPlaylist.isEmpty) return null;
    final idx = currentPlaylist.indexWhere((s) => s.number == currentSurah!.number);
    if (idx <= 0) return null;
    return currentPlaylist[idx - 1];
  }

  Future<void> loadSingleSurah(
      String audioUrl,
      Surah surah,
      Reciter reciter, {
        List<Surah>? playlist,
        Map<int, Reciter>? playlistReciters,
      }) async {
    try {
      await _saveCurrentListening();

      await _player.stop();

      currentSurah = surah;
      currentSurahNotifier.value = surah;

      currentReciter = reciter;
      if (playlist != null) currentPlaylist = playlist;
      if (playlistReciters != null) currentPlaylistReciters = playlistReciters;

      _playbackStartTime = DateTime.now();

      await _player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));

      final service = FlutterBackgroundService();
      await service.startService();

      isActiveNotifier.value = false;
      isActiveNotifier.value = true;

      await NotificationService.show(
        surahName: surah.nameSimple,
        reciterName: reciter.name,
      );

      await _player.play();
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  DateTime? _playbackStartTime;

  Future<void> _saveCurrentListening() async {
    if (currentSurah == null || _playbackStartTime == null) return;

    final minutes =
        DateTime.now().difference(_playbackStartTime!).inSeconds / 60;

    if (minutes < 0.1) return;

    try {
      await StatsService.recordListening(
        surahName: currentSurah!.nameSimple,
        surahNumber: currentSurah!.number,
        reciterName: currentReciter?.name ?? '',
        durationMinutes: minutes,
      );
    } catch (e) {
      debugPrint('Stats error: $e');
    }

    _playbackStartTime = null;
  }

  Future<void> playPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void toggleRepeat() {
    final current = _player.loopMode;
    _player.setLoopMode(
      current == LoopMode.one ? LoopMode.off : LoopMode.one,
    );
  }

  Future<void> playNext() async {
    final next = nextSurah;
    if (next == null || currentReciter == null) return;

    // use per-surah reciter if available, otherwise fall back to currentReciter
    final reciter = currentPlaylistReciters[next.number] ?? currentReciter!;

    final url = await QuranService.fetchSurahAudioUrl(reciter.id, next.number);
    await loadSingleSurah(url, next, reciter, playlist: currentPlaylist, playlistReciters: currentPlaylistReciters);
  }

  Future<void> playPrevious() async {
    final prev = previousSurah;
    if (prev == null || currentReciter == null) return;

    final reciter = currentPlaylistReciters[prev.number] ?? currentReciter!;

    final url = await QuranService.fetchSurahAudioUrl(reciter.id, prev.number);
    await loadSingleSurah(url, prev, reciter, playlist: currentPlaylist, playlistReciters: currentPlaylistReciters);
  }

  Future<void> stop() async {
    await _saveCurrentListening();
    await _player.stop();

    await NotificationService.cancel();

    currentSurah = null;
    currentReciter = null;
    currentPlaylist = [];

    isActiveNotifier.value = false;

    FlutterBackgroundService().invoke('stopService');
  }
}