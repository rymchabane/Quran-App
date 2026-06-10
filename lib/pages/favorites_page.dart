import 'package:flutter/material.dart';
import '../../models/surah_model.dart';
import '../../models/reciter_model.dart';
import '../../services/favorites_service.dart';
import '../../services/audio_player_service.dart';
import '../../services/api_service.dart';
import '../pages/player_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _audioService = AudioPlayerService();
  List<Map<String, dynamic>> _favorites = [];
  bool _loading = true;
  String _playingId = '';

  @override
  void initState() {
    super.initState();
    _load();
    FavoritesService.favoritesStream().listen((_) => _load());
  }

  Future<void> _load() async {
    try {
      final favs = await FavoritesService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _play(Map<String, dynamic> fav) async {
    final favSurahs = _favorites.map((f) => Surah(
      number: f['surahNumber'],
      nameArabic: f['surahNameArabic'] ?? '',
      nameSimple: f['surahName'] ?? '',
      nameTranslation: '',
      versesCount: 0,
      revelationPlace: '',
    )).toList();

    // build reciter map for each surah
    final playlistReciters = Map<int, Reciter>.fromEntries(
      _favorites.map((f) => MapEntry(
        f['surahNumber'] as int,
        Reciter(id: f['reciterId'], name: f['reciterName'] ?? '', style: ''),
      )),
    );

    final surah = favSurahs.firstWhere((s) => s.number == fav['surahNumber']);
    final reciter = Reciter(
      id: fav['reciterId'],
      name: fav['reciterName'] ?? '',
      style: '',
    );

    final audioUrl = await QuranService.fetchSurahAudioUrl(reciter.id, surah.number);
    await _audioService.loadSingleSurah(
      audioUrl, surah, reciter,
      playlist: favSurahs,
      playlistReciters: playlistReciters,
    );
  }

  Future<void> _remove(String id) async {
    final removed = await FavoritesService.removeFavoriteById(id);
    if (!removed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Biometric authentication required 🔒'),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          "Favorites",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C853), strokeWidth: 2),
      )
          : _favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 36,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No favorites yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap ♡ in the player to save a surah",
              style: TextStyle(color: Color(0xFF616161), fontSize: 14),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final fav = _favorites[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF222222)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Arabic name badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF00C853).withOpacity(0.2),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        fav['surahNameArabic'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF00C853),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fav['surahName'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            fav['reciterName'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF616161),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _playingId.isEmpty ? () => _play(fav) : null,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF00C853),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _remove(fav['id']),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
