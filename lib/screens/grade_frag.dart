import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grade_model.dart';
import '../services/grade_service.dart';
import '../services/student_service.dart';
import '../styles/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({Key? key}) : super(key: key);

  @override
  _GradeScreenState createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  List<Grade> allGrades = [];
  Map<String, List<Grade>> groupedGrades = {};
  bool isLoading = true;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadGrades();
  }

  Future<void> loadGrades() async {
    try {
      final List<Grade> grades = await GradeService.getAllGrades();
      setState(() {
        allGrades = grades;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print('Помилка завантаження оцінок: $e');
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    List<Grade> filteredGrades = filterGradesByDate(allGrades);
    filteredGrades = filterGradesBySearch(filteredGrades);
    setState(() {
      groupedGrades = groupGradesByDate(filteredGrades);
    });
  }

  List<Grade> filterGradesByDate(List<Grade> grades) {
    return grades.where((grade) {
      final DateTime date = grade.date;

      if (selectedStartDate != null && date.isBefore(selectedStartDate!)) {
        return false;
      }
      if (selectedEndDate != null && date.isAfter(selectedEndDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<Grade> filterGradesBySearch(List<Grade> grades) {
    if (searchQuery.isEmpty) return grades;

    return grades.where((grade) {
      return grade.subjectName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> pickStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.carribbeanCurrent,
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.white,
              hourMinuteTextColor: AppColors.carribbeanCurrent,
              dialHandColor: AppColors.carribbeanCurrent,
              dialBackgroundColor: AppColors.lightBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedStartDate = pickedDate;
      });
      _applyFilters();
    }
  }

  Future<void> pickEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.carribbeanCurrent,
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.white,
              hourMinuteTextColor: AppColors.carribbeanCurrent,
              dialHandColor: AppColors.carribbeanCurrent,
              dialBackgroundColor: AppColors.lightBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedEndDate = pickedDate;
      });
      _applyFilters();
    }
  }

  void clearFilters() {
    setState(() {
      selectedStartDate = null;
      selectedEndDate = null;
    });
    _applyFilters();
  }

  Map<String, List<Grade>> groupGradesByDate(List<Grade> grades) {
    Map<String, List<Grade>> grouped = {};
    for (var grade in grades) {
      String formattedDate = DateFormat('EEEE, d MMMM', 'uk').format(grade.date);
      grouped.putIfAbsent(formattedDate, () => []).add(grade);
    }
    return grouped;
  }

  Future<void> _exportGrades() async {
    try {
      final response = await StudentService.exportGradesToWord();
      final studentId = await StudentService.getStudentId();
      final student = await StudentService.getStudentById(studentId!);

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/ОцінкиЗвіт.docx';
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Файл успішно збережено')),
        );

        Share.shareXFiles([XFile(filePath)], text: 'Оцінки ${student.surname} ${student.name}');
      } else {
        throw Exception('Помилка завантаження файлу');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка експорту: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.moonstone,
        title: const Text('Мої оцінки', style: TextStyle(color: AppColors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
            tooltip: 'Експортувати оцінки',
            onPressed: _exportGrades,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateButton(
                        text: selectedStartDate == null
                            ? 'З: ---'
                            : 'З: ${DateFormat('dd.MM.yyyy').format(selectedStartDate!)}',
                        onPressed: pickStartDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDateButton(
                        text: selectedEndDate == null
                            ? 'До: ---'
                            : 'До: ${DateFormat('dd.MM.yyyy').format(selectedEndDate!)}',
                        onPressed: pickEndDate,
                      ),
                    ),
                    if (selectedStartDate != null || selectedEndDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: clearFilters,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    labelText: 'Пошук за предметом',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: AppColors.carribbeanCurrent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: AppColors.carribbeanCurrent,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.white2,
                    labelStyle: TextStyle(
                      color: AppColors.carribbeanCurrent,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: groupedGrades.isEmpty
                  ? const Center(child: Text('Немає оцінок'))
                  : Container(
                decoration: BoxDecoration(
                  color: AppColors.white2,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: groupedGrades.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.moonstone,
                            ),
                          ),
                        ),
                        ...entry.value.map((grade) => buildGradeTile(grade)).toList(),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({required String text, required VoidCallback onPressed}) {
    return TextButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white2,
        foregroundColor: AppColors.carribbeanCurrent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget buildGradeTile(Grade grade) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: getGradeColor(grade.grade),
        child: Text(
          grade.grade.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(grade.subjectName),
    );
  }

  Color getGradeColor(int grade) {
    if (grade >= 10) return Colors.green;
    if (grade >= 4) return Colors.orange;
    return Colors.red;
  }
}
