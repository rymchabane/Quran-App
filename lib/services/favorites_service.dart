import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class FavoritesService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _localAuth = LocalAuthentication();

  static String get _uid => _auth.currentUser!.uid;

  static CollectionReference get _favRef =>
      _firestore.collection('users').doc(_uid).collection('favorites');

  /// Stream of favorite IDs
  static Stream<List<String>> favoritesStream() {
    return _favRef.snapshots().map(
          (snap) => snap.docs.map((d) => d.id).toList(),
    );
  }

  /// Add a favorite surah by ID
  static Future<void> addFavoriteById({
    required String id,
    required int surahNumber,
    required String surahName,
    required String surahNameArabic,
    required int reciterId,
    required String reciterName,
    required String audioUrl,
  }) async {
    await _favRef.doc(id).set({
      'surahNumber': surahNumber,
      'surahName': surahName,
      'surahNameArabic': surahNameArabic,
      'reciterId': reciterId,
      'reciterName': reciterName,
      'audioUrl': audioUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a favorite by ID — requires biometric authentication
  static Future<bool> removeFavoriteById(String id) async {
    final canAuth = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();

    if (!canAuth || !isSupported) {
      await _favRef.doc(id).delete();
      return true;
    }

    final authenticated = await _localAuth.authenticate(
      localizedReason: 'Authenticate to remove this surah from favorites',
    );

    if (authenticated) {
      await _favRef.doc(id).delete();
      return true;
    }
    return false;
  }

  /// Fetch all favorites as raw maps
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final snap = await _favRef.orderBy('addedAt', descending: true).get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }
}