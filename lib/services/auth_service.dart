import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  // Secret suffix to bypass Firebase 6-character limit for 4-digit MPIN
  final String _mpinSuffix = "easycash_secure";

  // Sign Up
  Future<String?> signUp({
    required String fullName,
    required String phoneNumber,
    required String cnic,
    required String mpin,
  }) async {
    try {
      // Create email from phone number for Firebase Auth
      String email = "$phoneNumber@easycash.com";
      // Appending secret suffix to make 4-digit MPIN compatible with Firebase (min 6 chars)
      String securePassword = mpin + _mpinSuffix;

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: securePassword,
      );
      
      // Create user document in Firestore
      await _db.createUserData(fullName, phoneNumber, cnic);
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Login
  Future<String?> login({
    required String phoneNumber,
    required String mpin,
  }) async {
    try {
      String email = "$phoneNumber@easycash.com";
      String securePassword = mpin + _mpinSuffix;

      await _auth.signInWithEmailAndPassword(email: email, password: securePassword);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Change MPIN
  Future<String?> changeMpin({
    required String oldMpin,
    required String newMpin,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) return "User not logged in";

      // Re-authenticate first
      String secureOldPassword = oldMpin + _mpinSuffix;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: secureOldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update to new password
      String secureNewPassword = newMpin + _mpinSuffix;
      await user.updatePassword(secureNewPassword);

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Delete Account
  Future<String?> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // 1. Delete from Firestore
        await _db.deleteUserData();
        // 2. Delete from Auth
        await user.delete();
      }
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Current User
  User? get currentUser => _auth.currentUser;
}
