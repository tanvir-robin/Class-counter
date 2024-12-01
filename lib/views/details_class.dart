import 'package:flutter/material.dart';
import 'package:class_counter/db/firestore_helper.dart';
import 'package:intl/intl.dart';

class ClassDetailsScreen extends StatelessWidget {
  final String classId;
  final String courseTitle;
  final String courseCode;

  ClassDetailsScreen({
    required this.classId,
    required this.courseTitle,
    required this.courseCode,
  });

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseTitle),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: FutureBuilder(
        future: Future.wait([
          _firestoreService.getClassCount(classId),
          _firestoreService.getClassCountsByTeacher(classId),
          _firestoreService.getClassDetails(classId),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalClasses = snapshot.data?[0] ?? 0;
          final teacherCounts = snapshot.data?[1] as Map<String, int>;
          final classDetails = snapshot.data?[2] as List<Map<String, dynamic>>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$courseCode - $courseTitle',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total Classes: $totalClasses',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Class Counts by Teacher:',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...teacherCounts.entries.map((entry) {
                  return Text('${entry.key}: ${entry.value}');
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ListView.builder(
                          itemCount: classDetails.length,
                          itemBuilder: (context, index) {
                            final detail = classDetails[index];
                            return ListTile(
                              title: Text(
                                  DateFormat.yMMMd().format(detail['date'])),
                              subtitle: Text('Teacher: ${detail['teacher']}'),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Text('View All Class Details'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
