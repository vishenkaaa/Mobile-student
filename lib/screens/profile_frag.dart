import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/providers/auth_provider.dart';
import 'package:student_app/services/student_service.dart';
import '../models/student_model.dart';
import '../styles/colors.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Student? student;
  Student? tempStudent;
  bool isLoading = true;
  bool isEditing = false;

  late TextEditingController surnameController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController classController;
  DateTime? selectedDate;

  @override
  void dispose() {
    surnameController.dispose();
    nameController.dispose();
    emailController.dispose();
    classController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    surnameController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    classController = TextEditingController();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final studentId = await StudentService.getStudentId();
      if (studentId != null) {
        final _student = await StudentService.getStudentById(studentId);
        setState(() {
          student = _student;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Помилка завантаження даних: $e');
      setState(() => isLoading = false);
    }
  }

  void _startEditing() {
    if (student == null) return;

    tempStudent = Student(
      id: student!.id,
      email: student!.email,
      surname: student!.surname,
      name: student!.name,
      className: student!.className,
      dateOfBirth: student!.dateOfBirth,
    );

    surnameController.text = tempStudent!.surname;
    nameController.text = tempStudent!.name;
    emailController.text = tempStudent!.email;
    classController.text = tempStudent!.className;
    selectedDate = tempStudent!.dateOfBirth;

    setState(() {
      isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
    });
  }

  Future<void> _saveStudent() async {
    try {
      if (!_isValidEmail(emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Невірний формат email"))
        );
        return;
      }

      tempStudent = tempStudent?.copyWith(surname: surnameController.text) ;
      tempStudent = tempStudent?.copyWith(name: nameController.text);
      tempStudent = tempStudent?.copyWith(email: emailController.text);
      tempStudent = tempStudent?.copyWith(className: classController.text);
      tempStudent = tempStudent?.copyWith(dateOfBirth: selectedDate ?? tempStudent!.dateOfBirth);

      await StudentService.updateStudent(
          tempStudent!.id,
          tempStudent!.email,
          tempStudent!.surname,
          tempStudent!.name,
          tempStudent!.className,
          tempStudent!.dateOfBirth
      );

      setState(() {
        student = tempStudent;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Інформацію про учня успішно оновлено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка при оновленні інформації про учня'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      helpText: 'Виберіть дату народження',
      cancelText: 'Скасувати',
      confirmText: 'Вибрати',
      fieldLabelText: 'Дата народження',
      errorFormatText: 'Введіть дату у форматі ДД.ММ.РРРР',
      errorInvalidText: 'Введіть коректну дату',
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _logout(BuildContext context) async {
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  Color getRandomLightColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      200 + random.nextInt(56),
      200 + random.nextInt(56),
      200 + random.nextInt(56),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.moonstone,
        title: Text(
          isEditing ? 'Редагування профілю' : 'Профіль',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: isEditing
            ? [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: _cancelEditing,
            tooltip: 'Скасувати',
          ),
        ]
            : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : student == null
          ? Center(child: Text('Не вдалося завантажити профіль'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white2, width: 4.0),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: getRandomLightColor(),
                  child: Text(
                    '${student!.surname.substring(0, 1)}${student!.name.substring(0, 1)}',
                    style: TextStyle(fontSize: 50,),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isEditing
                    ? _buildEditForm()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Ім\'я:', '${student!.surname} ${student!.name}'),
                    _buildInfoRow('Email:', student!.email),
                    _buildInfoRow('Клас:', student!.className),
                    _buildInfoRow('Дата народження:', formatDate(student!.dateOfBirth)),
                  ],
                ),
              ),
              SizedBox(height: 20),

              if (isEditing)
                _buildButton(
                  icon: Icons.save,
                  text: 'Зберегти зміни',
                  color: AppColors.carribbeanCurrent,
                  onPressed: _saveStudent,
                )
              else
                _buildButton(
                  icon: Icons.edit,
                  text: 'Редагувати профіль',
                  color: AppColors.carribbeanCurrent,
                  onPressed: _startEditing,
                ),
              SizedBox(height: 16),

              if (!isEditing)
                _buildButton(
                  icon: Icons.exit_to_app,
                  text: 'Вийти',
                  color: Colors.redAccent,
                  onPressed: () => _logout(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Прізвище',
          controller: surnameController,
          icon: Icons.person,
        ),
        SizedBox(height: 12),
        _buildTextField(
          label: 'Ім\'я',
          controller: nameController,
          icon: Icons.person_outline,
        ),
        SizedBox(height: 12),
        _buildTextField(
          label: 'Email',
          controller: emailController,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 12),
        _buildTextField(
          label: 'Клас',
          controller: classController,
          icon: Icons.school,
        ),
        SizedBox(height: 12),
        _buildDatePicker(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.carribbeanCurrent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.carribbeanCurrent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.carribbeanCurrent, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Дата народження',
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.carribbeanCurrent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.carribbeanCurrent),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? formatDate(selectedDate!)
                  : formatDate(tempStudent!.dateOfBirth),
              style: TextStyle(fontSize: 16),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.carribbeanCurrent),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    try {
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return 'Невідома дата';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.carribbeanCurrent),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String text, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}