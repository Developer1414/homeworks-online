import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/custom_button.dart';
import 'package:scool_home_working/screens/new_estimate.dart';

class StudentProfile extends StatefulWidget {
  const StudentProfile(
      {super.key, required this.studentName, required this.studentId});

  final String studentName;
  final String studentId;

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final AppController appController = Get.find();
  DateTime? selectedDate = DateTime.now();

  RxBool isLoading = false.obs;

  Map<String, String> estimates = <String, String>{};

  Future getEstimates() async {
    FirebaseFirestore.instance
        .collection('classes')
        .doc(appController.classId.value)
        .collection('members')
        .doc('eSoiVBI7PwMQNoVxR8TSo9HM89O2')
        .collection('estimates')
        .where('date',
            isEqualTo: DateTime(
                selectedDate!.year, selectedDate!.month, selectedDate!.day))
        .get()
        .then((value) {
      // estimates.addAll({value.docs[0].get(''):});
    });
  }

  @override
  void initState() {
    super.initState();
    getEstimates();
  }

  @override
  Widget build(BuildContext mainContext) {
    return MaterialApp(
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
                bottomNavigationBar: customButton(
                    borderRadius: 15.0,
                    padding: const EdgeInsets.all(15.0),
                    onTap: () async {
                      Navigator.push(
                          mainContext,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  NewEstimate(studentId: widget.studentId))));
                    },
                    text: 'Новая оценка',
                    color: Colors.green),
                appBar: AppBar(
                  toolbarHeight: 100,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        splashRadius: 25.0,
                        onPressed: () =>
                            Navigator.pop(mainContext), //Get.back(),
                        icon: Icon(Icons.arrow_back_rounded,
                            color: Theme.of(mainContext).iconTheme.color,
                            size: 35)),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: AutoSizeText(
                      widget.studentName,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: Theme.of(mainContext).textTheme.displayLarge,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: IconButton(
                          padding: const EdgeInsets.all(0.0),
                          splashRadius: 28.0,
                          onPressed: () async {
                            DateTime? date = await showDatePicker(
                                context: mainContext,
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
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .color!,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .backgroundColor,
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Theme.of(mainContext).bottomSheetTheme.backgroundColor!,
                                                        width: 1,
                                                        style: BorderStyle.solid),
                                                    borderRadius: BorderRadius.circular(50))))),
                                    child: child!,
                                  );
                                });

                            selectedDate = date ?? selectedDate;
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.calendar_month_rounded,
                            color: Theme.of(mainContext).iconTheme.color,
                            size: 35,
                          )),
                    )
                  ],
                ),
                body: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('classes')
                            .doc(appController.classId.value)
                            .collection('members')
                            .doc('eSoiVBI7PwMQNoVxR8TSo9HM89O2')
                            .collection('estimates')
                            .where('date',
                                isEqualTo: DateTime(selectedDate!.year,
                                    selectedDate!.month, selectedDate!.day))
                            .snapshots(),
                        builder: (context, snapshot) {
                          return ListView.separated(
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
                                        /*Navigator.push(
                                                mainContext,
                                                MaterialPageRoute(
                                                    builder: ((context) =>
                                                        TaskSettings(
                                                            taskId: snapshot
                                                                .data?.docs[index]
                                                                .get('taskId')))));*/
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
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
                                                Text(
                                                  snapshot.data?.docs[index]
                                                      .get('subject'),
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
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: getEstimateColor(
                                                        snapshot
                                                            .data?.docs[index]
                                                            .get('estimate')),
                                                  ),
                                                  child: Center(
                                                    child: RichText(
                                                        textAlign:
                                                            TextAlign.center,
                                                        text:
                                                            TextSpan(children: [
                                                          TextSpan(
                                                            text: snapshot.data
                                                                ?.docs[index]
                                                                .get(
                                                                    'estimate'),
                                                            style: GoogleFonts.roboto(
                                                                textStyle: Theme.of(
                                                                        mainContext)
                                                                    .textTheme
                                                                    .titleSmall!
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .white)),
                                                          ),
                                                        ])),
                                                  ),
                                                )
                                                /*Text(
                                                  snapshot.data?.docs[index]
                                                      .get('estimate'),
                                                  style: Theme.of(mainContext)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          color: Theme.of(
                                                                  mainContext)
                                                              .textTheme
                                                              .titleSmall!
                                                              .color!
                                                              .withOpacity(
                                                                  0.9)),
                                                ),*/
                                              ],
                                            ),
                                          )),
                                    ),
                                  ),
                                );
                              });
                        })),
              ),
      ),
    );
  }

  Color getEstimateColor(String estimate) {
    if (estimate == '2' || estimate == 'П') {
      return Colors.red;
    } else if (estimate == '3') {
      return Colors.orange;
    } else if (estimate == '4' || estimate == '5') {
      return Colors.green;
    } else if (estimate == 'Н') {
      return Colors.grey;
    } else if (estimate == 'Б') {
      return Colors.blue;
    }

    return Colors.white;
  }
}
