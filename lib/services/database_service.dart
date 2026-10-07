import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create User Data in Firestore
  Future<void> createUserData(String fullName, String phoneNumber, String cnic) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'cnic': cnic,
        'balance': 1000.0, // Initial fake balance
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get User Data Stream
  Stream<DocumentSnapshot> get userData {
    User? user = _auth.currentUser;
    return _db.collection('users').doc(user?.uid).snapshots();
  }

  // Add Transaction to History (Fake Transaction)
  Future<void> addTransaction({
    required String bankName,
    required String accountNumber,
    required String amount,
    required String note,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      double parsedAmount = double.tryParse(amount) ?? 0.0;
      
      // Add to global transactions history
      await _db.collection('users').doc(user.uid).collection('transactions').add({
        'bankName': bankName,
        'accountNumber': accountNumber,
        'amount': amount,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'sent',
      });

      // Update balance (Fake update)
      DocumentReference userRef = _db.collection('users').doc(user.uid);
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (snapshot.exists) {
          double currentBalance = (snapshot.get('balance') ?? 0.0).toDouble();
          double newBalance = currentBalance - parsedAmount;
          transaction.update(userRef, {'balance': newBalance});
        } else {
          throw Exception("User data not found in Firestore. Please ensure you signed up correctly.");
        }
      });
    } else {
      throw Exception("User not logged in");
    }
  }

  // Get Transactions Stream
  Stream<QuerySnapshot> get transactions {
    User? user = _auth.currentUser;
    return _db
        .collection('users')
        .doc(user?.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Delete User Data Permanently
  Future<void> deleteUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Delete transactions sub-collection first
      var transactions = await _db.collection('users').doc(user.uid).collection('transactions').get();
      for (var doc in transactions.docs) {
        await doc.reference.delete();
      }
      // Delete user document
      await _db.collection('users').doc(user.uid).delete();
    }
  }
}
