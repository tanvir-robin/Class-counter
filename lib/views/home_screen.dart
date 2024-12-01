import 'package:class_counter/views/details_class.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:class_counter/db/firestore_helper.dart';
import 'package:class_counter/views/add_class.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _addClassCount(String classId, List<String> teachers) async {
    String? selectedTeacher = await showDialog(
      context: context,
      builder: (context) {
        String? teacher;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Select Teacher'),
          content: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            hint: const Text('Choose a teacher'),
            items: teachers
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              teacher = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, teacher),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );

    if (selectedTeacher != null) {
      await _firestoreService.addClassCount(
        classId: classId,
        teacherName: selectedTeacher,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Class count added!'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Counter'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final classes = snapshot.data?.docs ?? [];
          if (classes.isEmpty) {
            return const Center(
              child: Text(
                'No classes added yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              final classId = classData.id;
              final courseCode = classData['courseCode'];
              final courseTitle = classData['courseTitle'];
              final teachers = List<String>.from(classData['courseTeachers']);

              return FutureBuilder<int>(
                future: _firestoreService.getClassCount(classId),
                builder: (context, countSnapshot) {
                  final totalClasses = countSnapshot.data ?? 0;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    elevation: 6.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClassDetailsScreen(
                              classId: classId,
                              courseTitle: courseTitle,
                              courseCode: courseCode,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          courseCode.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      title: Text(
                        courseTitle,
                        style: const TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Total Classes: $totalClasses'),
                      trailing: ElevatedButton.icon(
                        onPressed: () => _addClassCount(classId, teachers),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddClassScreen()));
        },
        label: const Text('Add Class'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}
