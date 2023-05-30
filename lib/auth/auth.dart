import 'package:ar/auth/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Success";
    } catch (error) {
      return error.toString();
    }
  }

  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Success";
    } catch (error) {
      return error.toString();
    }
  }

  Future<String> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return "Success";
    } catch (error) {
      return error.toString();
    }
  }

  Future<bool> checkIfAdmin(String email) async {
    Database database = Database();
    bool isAdmin =
        await database.checkIfExists(path: "users/admin/list/$email");
    return isAdmin;
  }

  Future<bool> checkIfParent(String email) async {
    try {
      Database database = Database();
      bool isParent =
          await database.checkIfExists(path: "users/parent/list/$email");
      return isParent;
    } catch (e) {
      await Future.delayed(Duration(seconds: 3));
      return await checkIfParent(email);
    }
  }

  Future<bool> checkIfChild(String email) async {
    Database database = Database();
    bool isChild =
        await database.checkIfExistsWithin("users/child/list", "email", email);
    return isChild;
  }
}
