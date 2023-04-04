import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/dialog.dart';
import 'package:scool_home_working/models/subjects_sheet_model.dart';

class NewEstimate extends StatefulWidget {
  const NewEstimate(
      {super.key, this.changeEstimate = '', required this.studentId});

  final String changeEstimate;
  final String studentId;

  @override
  State<NewEstimate> createState() => _NewEstimateState();
}

class _NewEstimateState extends State<NewEstimate> {
  RxBool isLoading = false.obs;

  final AppController appController = Get.find();

  static TextEditingController subjectController = TextEditingController();
  static DateTime selectedDate = DateTime.now();
  static String selectedEstimate = '';

  void dismissKeyboardFocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    Widget estimateButton(String estimate, Color colorButton) {
      return Material(
        elevation: 0,
        color: colorButton,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(15.0),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedEstimate = estimate;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: selectedEstimate == estimate
                    ? Border.all(width: 3.0, color: Colors.white)
                    : null),
            child: Center(
                child: Text(estimate,
                    style: GoogleFonts.roboto(
                        fontSize: 22,
                        textStyle: Theme.of(mainContext)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.white)))),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => dismissKeyboardFocus,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
                        widget.changeEstimate.isEmpty
                            ? 'Новая оценка'
                            : 'Изменить оценку',
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: Theme.of(mainContext).textTheme.displayLarge,
                      ),
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: IconButton(
                          padding: const EdgeInsets.all(0.0),
                          splashRadius: 25.0,
                          onPressed: () => Navigator.pop(mainContext),
                          icon: Icon(Icons.arrow_back_rounded,
                              color: Theme.of(mainContext).iconTheme.color,
                              size: 35)),
                    ),
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
                                controller: subjectController,
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
                                  await modalBottomSheetSubjects(
                                      mainContext, subjectController);
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
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            estimateButton('2', Colors.red),
                            const SizedBox(width: 15.0),
                            estimateButton('3', Colors.orange),
                            const SizedBox(width: 15.0),
                            estimateButton('4', Colors.green),
                            const SizedBox(width: 15.0),
                            estimateButton('5', Colors.green),
                            const SizedBox(width: 15.0),
                            estimateButton('Н', Colors.grey),
                            const SizedBox(width: 15.0),
                            estimateButton('П', Colors.red),
                            const SizedBox(width: 15.0),
                            estimateButton('Б', Colors.blue),
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
                                child: Text(
                                    'Оценка на ${DateFormat.MMMMd('ru_RU').format(selectedDate)}',
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
                                          initialDate: selectedDate,
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
                              isLoading.value = true;

                              await FirebaseFirestore.instance
                                  .collection('classes')
                                  .doc(appController.classId.value)
                                  .collection('members')
                                  .doc(widget.studentId)
                                  .collection('estimates')
                                  .doc()
                                  .set({
                                'estimate': selectedEstimate,
                                'subject': subjectController.text,
                                'date': selectedDate,
                                'createDate': DateTime.now(),
                              }).whenComplete(() {
                                isLoading.value = false;

                                dialog(
                                  title: 'Уведомление',
                                  content: 'Оценка успешно добавлена!',
                                );

                                Navigator.pop(mainContext);
                              });
                            },
                            child: Text(
                              widget.changeEstimate.isEmpty
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
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
