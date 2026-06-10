import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';
import '../pages/player_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  void _openPlayerPage(BuildContext context, AudioPlayerService audioService) {
    print("OPEN PLAYER TRIGGERED");
    if (!AudioPlayerService.isPlayerPageOpen) {
      AudioPlayerService.isPlayerPageOpen = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerPage(
            reciter: audioService.currentReciter!,
            surah: audioService.currentSurah!,
            surahs: audioService.currentPlaylist,
          ),
        ),
      ).then((_) {
        AudioPlayerService.isPlayerPageOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AudioPlayerService.isActiveNotifier,
      builder: (context, isActive, _) {
        if (!isActive) return const SizedBox.shrink();

        final audioService = AudioPlayerService();
        final surah = audioService.currentSurah;
        final reciter = audioService.currentReciter;
        if (surah == null || reciter == null) return const SizedBox.shrink();

        return StreamBuilder<PlayerState>(
          stream: audioService.player.playerStateStream,
          builder: (context, snap) {
            final surah = audioService.currentSurah;
            final reciter = audioService.currentReciter;
            if (surah == null || reciter == null) return const SizedBox.shrink();

            final isPlaying = snap.data?.playing ?? false;
            final isLoading =
                snap.data?.processingState == ProcessingState.loading ||
                    snap.data?.processingState == ProcessingState.buffering;

            return Container(
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Partie gauche — ouvre le PlayerPage au tap
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _openPlayerPage(context, audioService),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              surah.nameArabic,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surah.nameSimple,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  reciter.name,
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Progress bar
                  Expanded(
                    child: StreamBuilder<Duration>(
                      stream: audioService.player.positionStream,
                      builder: (context, posSnap) {
                        return StreamBuilder<Duration?>(
                          stream: audioService.player.durationStream,
                          builder: (context, durSnap) {
                            final pos = posSnap.data ?? Duration.zero;
                            final dur = durSnap.data ?? Duration.zero;
                            final progress = dur.inMilliseconds > 0
                                ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
                                : 0.0;
                            return LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 2,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Bouton play/pause — GestureDetector absorbe le tap pour éviter la propagation
                  GestureDetector(
                    onTap: () {}, // absorbe le tap, empêche la propagation vers le parent
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => AudioPlayerService().playPause(),
                    ),
                  ),

                  // Bouton stop — GestureDetector absorbe le tap pour éviter la propagation
                  GestureDetector(
                    onTap: () {}, // absorbe le tap, empêche la propagation vers le parent
                    child: IconButton(
                      icon: const Icon(Icons.stop_rounded, color: Colors.white),
                      onPressed: () async => await AudioPlayerService().stop(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}