import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/task_model.dart';
import 'package:scool_home_working/screens/task_settings.dart';
import 'package:scool_home_working/themes/my_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  DateTime? selectedDate = DateTime.now();
  late SharedPreferences prefs;
  final AppController appController = Get.find();

  Future loadTasks() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('task')) {
      String? data = prefs.getString('task');
      appController.tasks.value = Task.decode(data!);
    }

    if (prefs.containsKey('selectedDate')) {
      String? date = prefs.getString('selectedDate');

      setState(() {
        selectedDate = DateTime.parse(date!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
    setState(() {
      appController.selectedTasks.clear();
    });
  }

  String tasksCount(int number) {
    if (((number % 100) > 10) && ((number % 100) < 20)) {
      return "заданий";
    }
    if (number % 10 == 1) {
      return "задание";
    }
    if ((number % 10 == 2) || (number % 10 == 3) || (number % 10 == 4)) {
      return "задания";
    }

    return "заданий";
  }

  @override
  Widget build(BuildContext mainContext) {
    final AppController appController = Get.put(AppController());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Theme.of(mainContext).backgroundColor,
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appController.classId.value.isNotEmpty
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('classes')
                          .doc(appController.classId.value)
                          .collection('homeworks')
                          .where('date', isEqualTo: selectedDate!)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return AutoSizeText(
                          '${snapshot.data?.docs.length ?? 0} ${tasksCount(snapshot.data?.docs.length ?? 0)}',
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          style: Theme.of(mainContext).textTheme.displayLarge,
                        );
                      })
                  : Container(),
              AutoSizeText(
                'на ${DateFormat.MMMMd('ru_RU').format(selectedDate!)}',
                maxLines: 1,
                textAlign: TextAlign.left,
                style: Theme.of(mainContext).textTheme.titleSmall,
              )
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                  padding: const EdgeInsets.all(0.0),
                  splashRadius: 28.0,
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime(2100),
                        helpText: 'Выберите дату',
                        cancelText: 'Отмена',
                        confirmText: 'Выбрать',
                        fieldLabelText: 'Напишите дату',
                        fieldHintText: 'ММ/ДД/ГГГГ',
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                    onPrimary: Colors.black87,
                                    onSurface: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .color!,
                                    primary: Colors.amber),
                                dialogBackgroundColor:
                                    Theme.of(context).backgroundColor,
                                textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .color!,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                        backgroundColor:
                                            Theme.of(context).backgroundColor,
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Theme.of(mainContext)
                                                    .bottomSheetTheme
                                                    .backgroundColor!,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            borderRadius:
                                                BorderRadius.circular(50))))),
                            child: child!,
                          );
                        });

                    selectedDate = date ?? selectedDate;
                    setState(() {});

                    await prefs.setString(
                        'selectedDate', selectedDate.toString());
                  },
                  icon: Icon(Icons.calendar_month_rounded,
                      color: Theme.of(mainContext).iconTheme.color, size: 35)),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: appController.classId.value.isNotEmpty
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('classes')
                      .doc(appController.classId.value)
                      .collection('homeworks')
                      .where('date', isEqualTo: selectedDate!)
                      .orderBy('createDate', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: LoadingIndicator(size: 55.0, borderWidth: 3.5),
                      );
                    }

                    return snapshot.data?.docs.length == 0
                        ? Container(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                'На этот день нет домашних заданий',
                                textAlign: TextAlign.center,
                                style: Theme.of(mainContext)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(mainContext)
                                          .textTheme
                                          .titleSmall!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 15.0),
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (ctx, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: Material(
                                  clipBehavior: Clip.antiAlias,
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (appController.isAdmin.value) {
                                        Navigator.push(
                                            mainContext,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    TaskSettings(
                                                        taskId: snapshot
                                                            .data?.docs[index]
                                                            .get('taskId')))));
                                        /*Get.to(() => TaskSettings(
                                            taskId: snapshot.data?.docs[index]
                                                .get('taskId')));*/
                                      }
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: snapshot.data?.docs[index]
                                                            .get('important')
                                                        as bool ==
                                                    true
                                                ? Colors.redAccent
                                                    .withOpacity(0.2)
                                                : Colors.transparent,
                                            border: Border.all(
                                                color: Theme.of(mainContext)
                                                    .textTheme
                                                    .titleMedium!
                                                    .color!
                                                    .withOpacity(0.2),
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              snapshot.data?.docs[index]
                                                              .get('important')
                                                          as bool ==
                                                      true
                                                  ? Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10.0),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .redAccent
                                                                    .withOpacity(
                                                                        0.8),
                                                                blurRadius:
                                                                    10.0)
                                                          ]),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(7.0),
                                                        child: AutoSizeText(
                                                          'ВАЖНОЕ ЗАДАНИЕ',
                                                          maxLines: 1,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                              Text(
                                                snapshot.data?.docs[index]
                                                    .get('taskName'),
                                                style: Theme.of(mainContext)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10.0, bottom: 10.0),
                                                color: Theme.of(mainContext)
                                                    .textTheme
                                                    .titleMedium!
                                                    .color!
                                                    .withOpacity(0.2),
                                                height: 2.0,
                                                width: double.infinity,
                                              ),
                                              Text(
                                                snapshot.data?.docs[index]
                                                    .get('task'),
                                                style: Theme.of(mainContext)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        color: Theme.of(
                                                                mainContext)
                                                            .textTheme
                                                            .titleSmall!
                                                            .color!
                                                            .withOpacity(0.9)),
                                              ),
                                            ],
                                          ),
                                        )

                                        /* ListTile(
                                    onTap: () {
                                      if (appController.isAdmin.value) {
                                        Get.to(() => TaskSettings(
                                            taskId: snapshot.data?.docs[index]
                                                .get('taskId')));
                                      }
                                    },
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0.0, bottom: 10.0),
                                          child: SizedBox(
                                            width: Get.width - 103,
                                            child: Text(
                                              snapshot.data?.docs[index].get('task'),
                                              style: Theme.of(mainContext)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      color: Theme.of(mainContext)
                                                          .textTheme
                                                          .titleSmall!
                                                          .color!
                                                          .withOpacity(0.9)),
                                            ),
                                          ),
                                        ),
                                        snapshot.data?.docs[index].get('edited')
                                                    as bool ==
                                                true
                                            ? Padding(
                                                padding: const EdgeInsets.all(7.0),
                                                child: AutoSizeText(
                                                  'Изменено',
                                                  maxLines: 1,
                                                  style: GoogleFonts.roboto(
                                                    color: Colors.orange,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),*/
                                        ),
                                  ),
                                ),
                              );
                            });
                  })
              : Container(),
        ),
      ),
    );
  }
}
