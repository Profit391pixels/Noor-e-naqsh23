
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  static const cols = ['dhagaEntries','paperRollEntries','thaanEntries','labourEntries','hallEntries','electricityEntries','firqiEntries','partyBills'];

  Stream<QuerySnapshot> streamCol(String col) => _db.collection(col).orderBy('date', descending: true).snapshots();

  Future<void> add(String col, Map<String,dynamic> data) => _db.collection(col).add(data);
  Future<void> update(String col, String id, Map<String,dynamic> data) => _db.collection(col).doc(id).update(data);
  Future<void> delete(String col, String id) => _db.collection(col).doc(id).delete();
}
