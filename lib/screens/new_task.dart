import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scool_home_working/controllers/ad_controller.dart';
import 'package:scool_home_working/main.dart';
import 'package:scool_home_working/models/dialog.dart';
import 'package:scool_home_working/models/subjects_sheet_model.dart';
import '../controllers/app_controller.dart';

class NewTask extends StatefulWidget {
  const NewTask({super.key, this.taskIdForChange = ''});

  final String taskIdForChange;

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  late DateTime? selectedDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  final AppController appController = Get.find();

  bool switchStatusNotice = false;
  bool switchStatusImportantTask = false;

  static TextEditingController titleController = TextEditingController();
  static TextEditingController taskController = TextEditingController();

  RxBool isLoading = false.obs;

  DateTime? selectedDateNotification = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  TimeOfDay? selectedTimeNotification = TimeOfDay.now();

  void dismissKeyboardFocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Future getTaskInfo() async {
    isLoading.value = true;

    await FirebaseFirestore.instance
        .collection('classes')
        .doc(appController.classId.value)
        .collection('homeworks')
        .doc(widget.taskIdForChange)
        .get()
        .then((value) {
      titleController.text = value.get('taskName');
      taskController.text = value.get('task');
      selectedDate = (value.get('date') as Timestamp).toDate();
      switchStatusImportantTask = value.get('important') as bool;
      isLoading.value = false;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.taskIdForChange.isNotEmpty) {
      getTaskInfo();
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    return GestureDetector(
      onTap: () {
        dismissKeyboardFocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Theme.of(mainContext).backgroundColor,
        home: Obx(
          () => isLoading.value
              ? Scaffold(
                  backgroundColor: Theme.of(mainContext).backgroundColor,
                  body: const Center(
                    child: LoadingIndicator(size: 55.0, borderWidth: 3.5),
                  ),
                )
              : Scaffold(
                  backgroundColor: Theme.of(mainContext).backgroundColor,
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    toolbarHeight: 100,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: AutoSizeText(
                        widget.taskIdForChange.isEmpty
                            ? 'Новое задание'
                            : 'Изменить задание',
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: Theme.of(mainContext).textTheme.displayLarge,
                      ),
                    ),
                    leading: widget.taskIdForChange.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: IconButton(
                                padding: const EdgeInsets.all(0.0),
                                splashRadius: 25.0,
                                onPressed: () =>
                                    Navigator.pop(mainContext), //Get.back(),
                                icon: Icon(Icons.arrow_back_rounded,
                                    color:
                                        Theme.of(mainContext).iconTheme.color,
                                    size: 35)),
                          )
                        : null,
                  ),
                  body: ListView(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15.0, bottom: 15.0),
                              child: TextField(
                                controller: titleController,
                                textInputAction: TextInputAction.next,
                                style:
                                    Theme.of(mainContext).textTheme.titleSmall!,
                                decoration: InputDecoration(
                                    hintText: 'Предмет...',
                                    hintStyle: Theme.of(mainContext)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: Theme.of(mainContext)
                                              .textTheme
                                              .titleSmall!
                                              .color!
                                              .withOpacity(0.5),
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            width: 2.0,
                                            color: Theme.of(mainContext)
                                                .textTheme
                                                .titleMedium!
                                                .color!
                                                .withOpacity(0.2))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: BorderSide(
                                            width: 2.5,
                                            color: Theme.of(context)
                                                .bottomSheetTheme
                                                .copyWith(
                                                    backgroundColor:
                                                        Theme.of(mainContext)
                                                            .textTheme
                                                            .titleSmall!
                                                            .color!
                                                            .withOpacity(0.4))
                                                .backgroundColor!))),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, bottom: 15.0),
                            child: IconButton(
                                padding: EdgeInsets.zero,
                                splashRadius: 25.0,
                                onPressed: () async {
                                  dismissKeyboardFocus();
                                  await modalBottomSheetSubjects(mainContext, titleController);
                                },
                                icon: Icon(
                                  Icons.menu_rounded,
                                  size: 35,
                                  color: Theme.of(mainContext)
                                      .textTheme
                                      .titleSmall!
                                      .color!
                                      .withOpacity(0.5),
                                )),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        child: SizedBox(
                          height: 200,
                          child: TextField(
                            controller: taskController,
                            textInputAction: TextInputAction.done,
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            textAlignVertical: TextAlignVertical.top,
                            style: Theme.of(mainContext).textTheme.titleSmall!,
                            decoration: InputDecoration(
                                hintText: 'Задание...',
                                hintStyle: Theme.of(mainContext)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(mainContext)
                                          .textTheme
                                          .titleSmall!
                                          .color!
                                          .withOpacity(0.5),
                                    ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(mainContext)
                                            .textTheme
                                            .titleMedium!
                                            .color!
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: BorderSide(
                                        width: 2.5,
                                        color: Theme.of(context)
                                            .bottomSheetTheme
                                            .copyWith(
                                                backgroundColor:
                                                    Theme.of(mainContext)
                                                        .textTheme
                                                        .titleSmall!
                                                        .color!
                                                        .withOpacity(0.4))
                                            .backgroundColor!))),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(mainContext)
                                    .textTheme
                                    .titleMedium!
                                    .color!
                                    .withOpacity(0.2),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 15.0, left: 15.0),
                                child: Text(
                                    'Задание на ${DateFormat.MMMMd('ru_RU').format(selectedDate!)}',
                                    style: Theme.of(mainContext)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            color: Theme.of(mainContext)
                                                .textTheme
                                                .titleSmall!
                                                .color!
                                                .withOpacity(0.8)))),
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: SizedBox(
                                height: 50,
                                width: 35,
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    splashRadius: 25.0,
                                    onPressed: () async {
                                      dismissKeyboardFocus();

                                      var date = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              selectedDate ?? DateTime.now(),
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
                                                  dialogBackgroundColor: Theme.of(context)
                                                      .backgroundColor,
                                                  textButtonTheme: TextButtonThemeData(
                                                      style: TextButton.styleFrom(
                                                          foregroundColor: Theme.of(context)
                                                              .textTheme
                                                              .titleSmall!
                                                              .color!,
                                                          textStyle: Theme.of(context)
                                                              .textTheme
                                                              .titleSmall,
                                                          backgroundColor: Theme.of(context)
                                                              .backgroundColor,
                                                          shape: RoundedRectangleBorder(
                                                              side: BorderSide(color: Theme.of(mainContext).bottomSheetTheme.backgroundColor!, width: 1, style: BorderStyle.solid),
                                                              borderRadius: BorderRadius.circular(50))))),
                                              child: child!,
                                            );
                                          });

                                      selectedDate = date ?? selectedDate;

                                      setState(() {});
                                    },
                                    icon: const Icon(
                                        Icons.calendar_month_rounded,
                                        color: Colors.indigoAccent,
                                        size: 30)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(mainContext)
                                    .textTheme
                                    .titleMedium!
                                    .color!
                                    .withOpacity(0.2),
                                width: 2.5),
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0, left: 15.0),
                              child: AutoSizeText('Важное задание:',
                                  maxLines: 2,
                                  style: Theme.of(mainContext)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          color: Theme.of(mainContext)
                                              .textTheme
                                              .titleSmall!
                                              .color!
                                              .withOpacity(0.8))),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FlutterSwitch(
                                activeColor: Colors.green,
                                inactiveColor: Theme.of(mainContext)
                                    .bottomSheetTheme
                                    .backgroundColor!,
                                width: 85.0,
                                height: 40.0,
                                toggleSize: 30.0,
                                value: switchStatusImportantTask,
                                borderRadius: 30.0,
                                padding: 6.0,
                                onToggle: (val) {
                                  setState(() {
                                    switchStatusImportantTask = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            onPressed: () async {
                              if (titleController.text.isEmpty) {
                                dialog(
                                    title: 'Ошибка',
                                    content: 'Вы не вписали название предмета!',
                                    isError: true);
                                return;
                              }

                              if (taskController.text.isEmpty) {
                                dialog(
                                    title: 'Ошибка',
                                    content: 'Вы не вписали задание!',
                                    isError: true);
                                return;
                              }

                              isLoading.value = true;

                              if (widget.taskIdForChange.isEmpty) {
                                await AdController()
                                    .showInterstitialAd(() async {
                                  final newTask = FirebaseFirestore.instance
                                      .collection('classes')
                                      .doc(appController.classId.value)
                                      .collection('homeworks')
                                      .doc(widget.taskIdForChange.isNotEmpty
                                          ? widget.taskIdForChange
                                          : null);

                                  await newTask.set({
                                    'taskName': titleController.text,
                                    'task': taskController.text,
                                    'date': selectedDate!,
                                    'important': switchStatusImportantTask,
                                    'createDate': DateTime.now(),
                                    'edited': widget.taskIdForChange.isNotEmpty,
                                    'taskId': newTask.id
                                  }).whenComplete(() {
                                    isLoading.value = false;
                                  }).whenComplete(() {
                                    dialog(
                                        title: 'Уведомление',
                                        content: 'Задание добавлено!');

                                    titleController.clear();
                                    taskController.clear();

                                    setState(() {
                                      switchStatusImportantTask = false;
                                    });
                                  });
                                });
                              } else {
                                FirebaseFirestore.instance
                                    .collection('classes')
                                    .doc(appController.classId.value)
                                    .collection('homeworks')
                                    .doc(widget.taskIdForChange)
                                    .update({
                                  'taskName': titleController.text,
                                  'task': taskController.text,
                                  'date': selectedDate!,
                                  'important': switchStatusImportantTask,
                                  'createDate': DateTime.now(),
                                  'edited': true,
                                }).whenComplete(() {
                                  isLoading.value = false;

                                  Navigator.of(context).pop();

                                  dialog(
                                      title: 'Уведомление',
                                      content: 'Задание изменено!');

                                  titleController.clear();
                                  taskController.clear();

                                  setState(() {
                                    switchStatusImportantTask = false;
                                  });
                                });
                              }
                            },
                            child: Text(
                              widget.taskIdForChange.isEmpty
                                  ? 'Добавить'
                                  : 'Изменить',
                              style: GoogleFonts.roboto(
                                  fontSize: 25,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15.0),
                        child: widget.taskIdForChange.isEmpty
                            ? AutoSizeText(
                                'После нажатия на кнопку «Добавить» воспроизведётся реклама, после чего Ваше задание будет добавлено.',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: Theme.of(mainContext)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        fontSize: 12,
                                        color: Theme.of(mainContext)
                                            .textTheme
                                            .titleSmall!
                                            .color!
                                            .withOpacity(0.6)))
                            : Container(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
