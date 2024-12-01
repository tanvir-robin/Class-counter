import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getClasses() {
    return _firestore.collection('classes').snapshots();
  }

  Future<int> getClassCount(String classId) async {
    final snapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('classCounts')
        .get();
    return snapshot.docs.length;
  }

  Future<Map<String, int>> getClassCountsByTeacher(String classId) async {
    final snapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('classCounts')
        .get();

    final Map<String, int> counts = {};
    for (var doc in snapshot.docs) {
      final teacher = doc['teacherName'];
      counts[teacher] = (counts[teacher] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<Map<String, dynamic>>> getClassDetails(String classId) async {
    final snapshot = await _firestore
        .collection('classes')
        .doc(classId)
        .collection('classCounts')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'date': doc['date'].toDate(), // Assuming Firestore Timestamp
        'teacher': doc['teacherName'],
      };
    }).toList();
  }

  Future<void> addClassCount({
    required String classId,
    required String teacherName,
  }) async {
    final doc = _firestore
        .collection('classes')
        .doc(classId)
        .collection('classCounts')
        .doc();
    await doc.set({
      'teacherName': teacherName,
      'date': Timestamp.now(),
    });
  }

  // Add the missing addClass method
  Future<void> addClass({
    required String courseCode,
    required String courseTitle,
    required List<String> courseTeachers,
  }) async {
    final doc = _firestore.collection('classes').doc();
    await doc.set({
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'courseTeachers': courseTeachers,
    });
  }
}
