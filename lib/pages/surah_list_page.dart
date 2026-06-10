import 'package:flutter/material.dart';
import '../../models/reciter_model.dart';
import '../../models/surah_model.dart';
import '../../services/api_service.dart';
import '../../services/audio_player_service.dart';
import 'player_page.dart';

class SurahListPage extends StatefulWidget {
  final Reciter reciter;
  const SurahListPage({super.key, required this.reciter});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  List<Surah> _surahs = [];
  List<Surah> _filtered = [];
  bool _loading = true;
  bool _isLoadingAudio = false;
  final _search = TextEditingController();
  final _audioService = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() {
      final q = _search.text.toLowerCase();
      setState(() {
        _filtered = _surahs
            .where((s) =>
                s.nameSimple.toLowerCase().contains(q) ||
                s.number.toString().contains(q))
            .toList();
      });
    });
  }

  Future<void> _load() async {
    try {
      final surahs = await QuranService.fetchSurahs();
      setState(() {
        _surahs = surahs;
        _filtered = surahs;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _playSurah(Surah surah) async {
    if (_isLoadingAudio) return;
    setState(() => _isLoadingAudio = true);

    try {
      final audioUrl = await QuranService.fetchSurahAudioUrl(
        widget.reciter.id,
        surah.number,
      );
      await _audioService.loadSingleSurah(
        audioUrl,
        surah,
        widget.reciter,
        playlist: _surahs,
      );
      AudioPlayerService.isActiveNotifier.value = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Audio not available for this reciter'),
            backgroundColor: const Color(0xFF1E1E1E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() => _isLoadingAudio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.reciter.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.reciter.style.isNotEmpty)
              Text(
                widget.reciter.style,
                style: const TextStyle(color: Color(0xFF616161), fontSize: 12),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: TextField(
                controller: _search,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Search surah...",
                  hintStyle: TextStyle(color: Color(0xFF424242), fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF424242), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853), strokeWidth: 2),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final surah = _filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: _isLoadingAudio ? null : () => _playSurah(surah),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF222222)),
                      ),
                      child: Row(
                        children: [
                          // Number badge
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${surah.number}',
                              style: const TextStyle(
                                color: Color(0xFF00C853),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surah.nameSimple,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${surah.versesCount} verses • ${surah.revelationPlace}',
                                  style: const TextStyle(
                                    color: Color(0xFF616161),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            surah.nameArabic,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF00C853),
                              fontFamily: 'Amiri',
                            ),
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
