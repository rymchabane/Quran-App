import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  bool isAtLeast13(DateTime dob) {
    final now = DateTime.now();
    return now.year - dob.year >= 13;
  }

  Future<bool> signup({
    required String firstName,
    required String lastName,
    required DateTime dob,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection("users").doc(cred.user!.uid).set({
        "firstName": firstName,
        "lastName": lastName,
        "dob": dob.toString().split(" ")[0],
        "email": email,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>> getProfile(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    return doc.data()!;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("Aucun utilisateur trouvé pour cet email.");
      } else {
        print("Erreur : ${e.message}");
      }
    }
  }
}