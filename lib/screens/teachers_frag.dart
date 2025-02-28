import 'package:flutter/material.dart';
import 'package:student_app/models/teacher_model.dart';
import 'package:student_app/models/subject_model.dart';
import 'package:student_app/services/teacher_service.dart';
import 'package:student_app/services/subject_service.dart';
import 'package:student_app/styles/colors.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({Key? key}) : super(key: key);

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  List<Teacher> teachers = [];
  Map<String, List<Subject>> teacherSubjects = {};
  Set<String> expandedTeachers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeachersData();
  }

  Future<void> loadTeachersData() async {
    try {
      final _teachers = await TeacherService.getStudentTeachers();
      setState(() {
        teachers = _teachers;
        isLoading = false;
      });
    } catch (e) {
      print('Помилка завантаження даних: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> loadTeacherSubjects(String teacherId) async {
    if (teacherSubjects.containsKey(teacherId)) return;

    try {
      final subjects = await SubjectService.getAllTeacherSubjects(teacherId);
      setState(() {
        teacherSubjects[teacherId] = subjects;
      });
    } catch (e) {
      print('Помилка завантаження предметів вчителя: $e');
    }
  }

  void toggleTeacherExpansion(String teacherId) {
    setState(() {
      if (expandedTeachers.contains(teacherId)) {
        expandedTeachers.remove(teacherId);
      } else {
        expandedTeachers.add(teacherId);
        loadTeacherSubjects(teacherId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.moonstone,
        title: const Text(
          'Мої вчителі',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white2,
            borderRadius: BorderRadius.circular(15),
          ),
          child: teachers.isEmpty
              ? const Center(child: Text('Немає вчителів'))
              : ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              final isExpanded = expandedTeachers.contains(teacher.id);
              final subjects = teacherSubjects[teacher.id] ?? [];
              final isLoading = isExpanded && !teacherSubjects.containsKey(teacher.id);

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.carribbeanCurrent),
                    title: Text("${teacher.surname} ${teacher.name} ${teacher.fatherName}"),
                    trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                    onTap: () => toggleTeacherExpansion(teacher.id),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                          : subjects.isEmpty
                          ? const Text('Немає предметів')
                          : Column(
                        children: subjects
                            .map((subject) => ListTile(
                          title: Text(subject.name),
                          leading: const Icon(Icons.book, color: AppColors.moonstone),
                        ))
                            .toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}