import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reciter_model.dart';
import '../models/surah_model.dart';

class QuranService {
  static const String _base = 'https://api.quran.com/api/v4';

  // Fetch all reciters
  static Future<List<Reciter>> fetchReciters() async {
    final res = await http.get(Uri.parse('$_base/resources/recitations'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data['recitations'];
      return list.map((r) => Reciter.fromJson(r)).toList();
    }
    throw Exception('Failed to load reciters');
  }

  // Fetch all 114 surahs
  static Future<List<Surah>> fetchSurahs() async {
    final res = await http.get(Uri.parse('$_base/chapters?language=en'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List list = data['chapters'];
      return list.map((s) => Surah.fromJson(s)).toList();
    }
    throw Exception('Failed to load surahs');
  }

  // Get audio URL for a reciter + surah (full surah MP3 from CDN)
  /// Fetch the real audio URL for a reciter + surah from the API
  static Future<String> fetchSurahAudioUrl(int reciterId, int surahNumber) async {
    final res = await http.get(
      Uri.parse('$_base/chapter_recitations/$reciterId/$surahNumber'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['audio_file']['audio_url'];
    }
    throw Exception('Failed to load audio URL');
  }
}