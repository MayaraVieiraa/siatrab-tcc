import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('users').doc(_uid).collection('calculations');

  Future<String> saveCalculation(Map<String, dynamic> data) async {
    final doc = await _collection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<List<Map<String, dynamic>>> watchCalculations() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => {'firestoreId': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> deleteCalculation(String firestoreId) async {
    await _collection.doc(firestoreId).delete();
  }
}

final historyRepository = HistoryRepository();
