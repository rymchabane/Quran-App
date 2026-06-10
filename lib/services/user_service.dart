import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> addFavorite({
    required String title,
    required String artist,
  }) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .add({
      "title": title,
      "artist": artist,
      "addedAt": Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addListening({
    required String title,
    required int duration,
  }) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("listening")
        .add({
      "title": title,
      "duration": duration,
      "date": Timestamp.now(),
    });
  }
}