import 'package:class_counter/db/firestore_helper.dart';
import 'package:flutter/material.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({Key? key}) : super(key: key);

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();
  final List<String> _teachers = [];

  final FirestoreService _firestoreService = FirestoreService();

  void _addTeacher() {
    if (_teacherController.text.isNotEmpty) {
      setState(() {
        _teachers.add(_teacherController.text);
        _teacherController.clear();
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _firestoreService.addClass(
        courseCode: _courseCodeController.text,
        courseTitle: _courseTitleController.text,
        courseTeachers: _teachers,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Class added successfully!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Class')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _courseCodeController,
                decoration: InputDecoration(
                  labelText: 'Course Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter course code' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseTitleController,
                decoration: InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter course title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teacherController,
                decoration: InputDecoration(
                  labelText: 'Teacher Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _addTeacher,
                    child: const Text('Add Teacher'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Teachers: ${_teachers.join(', ')}',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save Class'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 16.0,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
