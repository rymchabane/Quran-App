import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/surah_model.dart';
import '../../models/reciter_model.dart';
import '../../services/audio_player_service.dart';
import '../../services/favorites_service.dart';
import '../../services/api_service.dart';

class PlayerPage extends StatefulWidget {
  final Reciter reciter;
  final Surah surah;
  final List<Surah> surahs;

  const PlayerPage({
    super.key,
    required this.reciter,
    required this.surah,
    required this.surahs,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final _audioService = AudioPlayerService();
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    FavoritesService.favoritesStream().listen((ids) {
      if (mounted) setState(() => _favoriteIds = ids.toSet());
    });
    AudioPlayerService.isActiveNotifier.addListener(() {
      if (mounted) setState(() {});
    });
    _audioService.player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) _playNext();
    });
  }

  Surah get _currentSurah => _audioService.currentSurah ?? widget.surah;
  String get _favId => 'surah_${_currentSurah.number}_${widget.reciter.id}';

  Future<void> _toggleFavorite() async {
    if (_favoriteIds.contains(_favId)) {
      final removed = await FavoritesService.removeFavoriteById(_favId);
      if (!removed && mounted) {
        _showSnack('Biometric authentication required 🔒');
      }
    } else {
      await FavoritesService.addFavoriteById(
        id: _favId,
        surahNumber: _currentSurah.number,
        surahName: _currentSurah.nameSimple,
        surahNameArabic: _currentSurah.nameArabic,
        reciterId: widget.reciter.id,
        reciterName: widget.reciter.name,
        audioUrl: await QuranService.fetchSurahAudioUrl(
            widget.reciter.id, _currentSurah.number),
      );
      if (mounted) _showSnack('Added to favorites ❤️');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _playNext() async {
    await _audioService.playNext();
    if (mounted) setState(() {});
  }

  Future<void> _playPrevious() async {
    await _audioService.playPrevious();
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayerService().player;
    final isFav = _favoriteIds.contains(_favId);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              _audioService.currentReciter?.name ?? widget.reciter.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.reciter.style.isNotEmpty)
              Text(
                _audioService.currentReciter?.style ?? widget.reciter.style,
                style: const TextStyle(color: Color(0xFF616161), fontSize: 11),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _toggleFavorite,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isFav
                      ? Colors.red.withOpacity(0.12)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFav
                        ? Colors.red.withOpacity(0.3)
                        : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : const Color(0xFF616161),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Artwork
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album art
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.08),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentSurah.nameArabic,
                            style: const TextStyle(
                              fontSize: 36,
                              color: Color(0xFF00C853),
                              fontFamily: 'Amiri',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            width: 80,
                            color: const Color(0xFF2A2A2A),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_currentSurah.number}',
                            style: const TextStyle(
                              color: Color(0xFF424242),
                              fontSize: 13,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Surah name
                    Text(
                      _currentSurah.nameSimple,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentSurah.nameTranslation,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
                    ),

                    if (_currentSurah.revelationPlace.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00C853).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          _currentSurah.revelationPlace.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Progress bar
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, posSnap) {
                  return StreamBuilder<Duration?>(
                    stream: player.durationStream,
                    builder: (context, durSnap) {
                      final pos = posSnap.data ?? Duration.zero;
                      final dur = durSnap.data ?? Duration.zero;
                      final progress = dur.inMilliseconds > 0
                          ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
                          : 0.0;
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF00C853),
                              inactiveTrackColor: const Color(0xFF222222),
                              thumbColor: const Color(0xFF00C853),
                              overlayColor: const Color(0xFF00C853).withOpacity(0.1),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: (v) {
                                final ms = (v * dur.inMilliseconds).round();
                                AudioPlayerService().seekTo(Duration(milliseconds: ms));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(pos),
                                  style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
                                ),
                                Text(
                                  _formatDuration(dur),
                                  style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              // Controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF1E1E1E)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Repeat
                    StreamBuilder<LoopMode>(
                      stream: player.loopModeStream,
                      builder: (context, snap) {
                        final isRepeat = snap.data == LoopMode.one;
                        return _controlButton(
                          icon: Icons.repeat_one_rounded,
                          color: isRepeat ? const Color(0xFF00C853) : const Color(0xFF424242),
                          onTap: () {
                            AudioPlayerService().toggleRepeat();
                            setState(() {});
                          },
                          size: 22,
                        );
                      },
                    ),

                    // Previous
                    _controlButton(
                      icon: Icons.skip_previous_rounded,
                      color: AudioPlayerService().previousSurah != null
                          ? Colors.white
                          : const Color(0xFF2A2A2A),
                      onTap: AudioPlayerService().previousSurah != null ? _playPrevious : null,
                      size: 32,
                    ),

                    // Play/Pause
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snap) {
                        final isPlaying = snap.data?.playing ?? false;
                        final isLoading =
                            snap.data?.processingState == ProcessingState.loading ||
                                snap.data?.processingState == ProcessingState.buffering;
                        return GestureDetector(
                          onTap: () => AudioPlayerService().playPause(),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00C853).withOpacity(0.25),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: isLoading
                                ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 36,
                            ),
                          ),
                        );
                      },
                    ),

                    // Next
                    _controlButton(
                      icon: Icons.skip_next_rounded,
                      color: AudioPlayerService().nextSurah != null
                          ? Colors.white
                          : const Color(0xFF2A2A2A),
                      onTap: AudioPlayerService().nextSurah != null ? _playNext : null,
                      size: 32,
                    ),

                    // Queue
                    _controlButton(
                      icon: Icons.queue_music_rounded,
                      color: const Color(0xFF424242),
                      onTap: () => Navigator.pop(context),
                      size: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    double size = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: size),
    );
  }
}
