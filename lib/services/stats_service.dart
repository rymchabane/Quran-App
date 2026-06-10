import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsService {
  static final _db = FirebaseFirestore.instance;

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Appelé quand une surah commence à jouer
  static Future<void> recordListening({
    required String surahName,
    required int surahNumber,
    required String reciterName,
    required double durationMinutes,
  }) async {
    final uid = _uid;
    final now = DateTime.now();

    // 1. Ajouter une entrée d'écoute
    await _db
        .collection('users')
        .doc(uid)
        .collection('listening')
        .add({
      'surahName': surahName,
      'surahNumber': surahNumber,
      'reciterName': reciterName,
      'duration': durationMinutes,
      'date': Timestamp.fromDate(now),
    });

    // 2. Mettre à jour le compteur de la surah dans "songs"
    final songRef = _db
        .collection('users')
        .doc(uid)
        .collection('songs')
        .doc('surah_$surahNumber');

    final songDoc = await songRef.get();
    if (songDoc.exists) {
      await songRef.update({'plays': FieldValue.increment(1)});
    } else {
      await songRef.set({
        'title': surahName,
        'surahNumber': surahNumber,
        'reciterName': reciterName,
        'plays': 1,
      });
    }
  }
}