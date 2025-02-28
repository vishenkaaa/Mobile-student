import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:student_app/models/schedule_model.dart';
import 'package:student_app/services/schedule_service.dart';
import 'package:student_app/services/config_service.dart';
import 'package:student_app/styles/colors.dart';

import '../models/subject_model.dart';
import '../services/student_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Map<int, List<Schedule>> groupedSchedule = {};
  bool isLoading = true;
  String lessonStartTime = "08:00";
  int bigBreakAfter = 3;
  int bigBreakDuration = 20;
  int smallBreakDuration = 10;

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  Future<void> loadSchedule () async {
    try{
      final studentId = await StudentService.getStudentId();
      if (studentId != null){
        final scheduleData = await ScheduleService.getSchedule(studentId);
        final settings = await ConfigService.getSettings();

        setState(() {
          groupedSchedule = groupByDay(scheduleData);
          lessonStartTime = settings['lessonStartTime'] ?? "8:00";
          bigBreakAfter = settings['bigBreakAfter'] ?? 3;
          bigBreakDuration = settings['bigBreakDuration'] ?? 20;
          smallBreakDuration = settings['smallBreakDuration'] ?? 10;
          isLoading = false;
        });
      }
    }
    catch (e) {
      print('Помилка завантаження розкладу: $e');
      setState(() => isLoading = false);
    }
  }

  Map<int, List<Schedule>> groupByDay (List<Schedule> schedule){
    Map<int, List<Schedule>> grouped = {};

    for (var lesson in schedule){
      grouped.putIfAbsent(lesson.dayOfWeek, () => []).add(lesson);
    }

    for (var day in grouped.keys){
      grouped[day]!.sort((a,b) => a.lessonNumber.compareTo(b.lessonNumber));
    }

    return grouped;
  }

  String getWeekDay(int day){
    switch(day){
      case 1: return 'Понеділок';
      case 2: return 'Вівторок';
      case 3: return 'Середа';
      case 4: return 'Четвер';
      case 5: return 'П’ятниця';
      case 6: return 'Субота';
      default: return 'Невідомий день';
    }
  }

  List<String> calculateLessonTimes(){
    List <String> lessonTimes = [];
    DateTime startTime = DateFormat.Hm().parse(lessonStartTime);

    for(int i = 1; i <= 6; i++){
      DateTime endTime = startTime.add(const Duration(minutes: 45));
      lessonTimes.add("${DateFormat.Hm().format(startTime)} - ${DateFormat.Hm().format(endTime)}");

      if (i == bigBreakAfter){
        startTime = endTime.add(Duration(minutes: bigBreakDuration));
      }
      else startTime = endTime.add(Duration(minutes: smallBreakDuration));
    }

    return lessonTimes;
  }

  @override
  Widget build(BuildContext context) {
    List <String> lessonTimes = calculateLessonTimes();

    return Scaffold(
        backgroundColor: AppColors.lightBlue,
        appBar: AppBar(
          backgroundColor: AppColors.moonstone,
          title: const Text('Мій розклад', style: TextStyle(color: AppColors.white)),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : groupedSchedule.isEmpty
            ? const Center(child: Text('Розклад відсутній'))
            : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white2,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, dayIndex){
                  int dayOfWeek = dayIndex+1;
                  List<Schedule> lessons = groupedSchedule[dayOfWeek] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: AppColors.carribbeanCurrent.withOpacity(0.8),
                        child: Text(
                          getWeekDay(dayOfWeek),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Table(
                        border: TableBorder.all(color: AppColors.grey),
                        columnWidths: const {
                          0: FixedColumnWidth(50),
                          1: FixedColumnWidth(100),
                          2: FlexColumnWidth(),
                        },
                        children: List.generate(6, (lessonNumber){
                          Schedule? lesson = lessons.firstWhere(
                                (l) => l.lessonNumber == lessonNumber + 1,
                            orElse: () => Schedule(
                                id: '',
                                dayOfWeek: dayOfWeek,
                                lessonNumber: lessonNumber + 1,
                                subject: Subject(id: '', name: '—', teacherId: '', hoursPerWeek: 0)
                            ),
                          );

                          return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text('${lesson.lessonNumber}', textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(lessonTimes[lessonNumber], textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    lesson.subject.name,
                                    style: TextStyle(
                                      fontWeight: lesson.subject.name == '—' ? FontWeight.normal : FontWeight.bold,
                                      color: lesson.subject.name == '—' ? AppColors.grey : AppColors.black,
                                    ),
                                  ),
                                ),
                              ]
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            )
        )
    );
  }
}