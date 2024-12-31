import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký với email và password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Tạo user với email và password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thêm thông tin username vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      // Cập nhật displayName trong Firebase Auth
      await userCredential.user!.updateDisplayName(username);

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Đăng nhập với email và password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Đăng nhập với Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Kiểm tra xem user đã tồn tại trong Firestore chưa
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Nếu chưa tồn tại, tạo document mới
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'createdAt': Timestamp.now(),
        });
      }

      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Xử lý các exception từ Firebase Auth
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        default:
          return 'An undefined error occurred.';
      }
    }
    return e.toString();
  }

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Stream để theo dõi thay đổi trạng thái authentication
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
