import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/custom_button.dart';
import 'package:scool_home_working/models/dialog.dart';
import 'package:scool_home_working/screens/app_settings.dart';
import 'package:scool_home_working/screens/class_settings.dart';
import 'package:scool_home_working/screens/login.dart';
import 'package:scool_home_working/screens/student_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyClass extends StatefulWidget {
  const MyClass({super.key});

  @override
  State<MyClass> createState() => _MyClassState();
}

class _MyClassState extends State<MyClass> with WidgetsBindingObserver {
  final AppController appController = Get.put(AppController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    changeUserStatus('online');
  }

  Future changeUserStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(appController.classId.value)
        .collection('members')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'status': status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      changeUserStatus('online');
    } else {
      changeUserStatus(DateTime.now().toString());
    }
  }

  String getUserStatus(String status) {
    if (status == 'online') {
      return 'В сети';
    } else {
      String date = '';

      DateTime dt1 = DateTime.parse(status);
      DateTime dt2 = DateTime.now();

      if (((dt2.difference(dt1).inHours / 24).abs()).round() < 1 &&
          dt1.day == dt2.day) {
        date = 'Был(а) в ${DateFormat.jm('ru_RU').format(dt1)}';
      } else {
        date =
            'Был(а) ${DateFormat.MMMd('ru_RU').format(dt1)} в ${DateFormat.jm('ru_RU').format(dt1)}';
      }

      return date;
    }
  }

  @override
  Widget build(BuildContext mainContext) {
    String peoplesCount(int number) {
      if (((number % 100) > 10) && ((number % 100) < 20)) {
        return "человек";
      }
      if (number % 10 == 1) {
        return "человек";
      }
      if ((number % 10 == 2) || (number % 10 == 3) || (number % 10 == 4)) {
        return "человека";
      }

      return "человек";
    }

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
              AutoSizeText(
                'Мой класс',
                maxLines: 1,
                textAlign: TextAlign.left,
                style: Theme.of(mainContext).textTheme.displayLarge,
              ),
              appController.classId.value.isNotEmpty
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('classes')
                          .doc(appController.classId.value)
                          .collection('members')
                          .where('exiled', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return AutoSizeText(
                            '${snapshot.data?.docs.length ?? 0} ${peoplesCount(snapshot.data?.docs.length ?? 0)}:',
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            style: Theme.of(mainContext).textTheme.titleSmall);
                      })
                  : Container(),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                  padding: const EdgeInsets.all(0.0),
                  splashRadius: 28.0,
                  onPressed: () async {
                    await Get.bottomSheet(Container(
                      height: 190.0,
                      margin: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                          color: Theme.of(mainContext).backgroundColor,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Column(
                        children: [
                          Container(
                            height: 8.0,
                            width: 70.0,
                            margin: const EdgeInsets.only(top: 15.0),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                          customButton(
                              text: 'Настройки класса',
                              color: Theme.of(mainContext)
                                  .bottomSheetTheme
                                  .backgroundColor!,
                              textColor: Theme.of(mainContext)
                                  .textTheme
                                  .titleMedium!
                                  .color!
                                  .withOpacity(0.9),
                              padding: const EdgeInsets.only(
                                  top: 15.0, left: 15.0, right: 15.0),
                              onTap: () {
                                Get.back();
                                //Get.to(() => const ClassSettings());

                                Navigator.push(
                                    mainContext,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const ClassSettings())));
                              }),
                          customButton(
                              text: 'Настройки приложения',
                              color: Theme.of(mainContext)
                                  .bottomSheetTheme
                                  .backgroundColor!,
                              textColor: Theme.of(mainContext)
                                  .textTheme
                                  .titleMedium!
                                  .color!
                                  .withOpacity(0.9),
                              padding: const EdgeInsets.only(
                                  top: 15.0, left: 15.0, right: 15.0),
                              onTap: () {
                                Get.back();

                                /*Get.to(() =>
                                    AppSettings(buildContext: mainContext));*/

                                Navigator.push(
                                    mainContext,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const AppSettings())));
                              }),
                        ],
                      ),
                    ));
                  },
                  icon: Icon(
                    Icons.settings_rounded,
                    color: Theme.of(mainContext).iconTheme.color,
                    size: 35,
                  )),
            )
          ],
        ),
        body: appController.classId.value.isEmpty
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('classes')
                        .doc(appController.classId.value)
                        .collection('members')
                        .where('exiled', isEqualTo: false)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: LoadingIndicator(size: 55.0, borderWidth: 3.5),
                        );
                      }

                      return ListView.separated(
                          itemCount: snapshot.data?.docs.length ?? 0,
                          separatorBuilder: (ctx, index) =>
                              const SizedBox(height: 5.0),
                          itemBuilder: (ctx, index) {
                            return ListTile(
                              onTap: () async {
                                if (appController.teacherId.value !=
                                        FirebaseAuth
                                            .instance.currentUser!.uid ||
                                    snapshot.data?.docs[index].get('uid') ==
                                        FirebaseAuth
                                            .instance.currentUser!.uid) {
                                  return;
                                }

                                await Get.bottomSheet(Container(
                                  height: 263.0,
                                  margin: const EdgeInsets.all(15.0),
                                  decoration: BoxDecoration(
                                      color:
                                          Theme.of(mainContext).backgroundColor,
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 8.0,
                                        width: 70.0,
                                        margin:
                                            const EdgeInsets.only(top: 15.0),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade700,
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                      ),
                                      customButton(
                                          text: 'Профиль ученика (скоро)',
                                          color: Theme.of(mainContext)
                                              .bottomSheetTheme
                                              .backgroundColor!,
                                          textColor: Theme.of(mainContext)
                                              .textTheme
                                              .titleMedium!
                                              .color!
                                              .withOpacity(0.4),
                                          padding: const EdgeInsets.only(
                                              top: 15.0,
                                              left: 15.0,
                                              right: 15.0),
                                          onTap: () {
                                            /*Get.back();

                                            Navigator.push(
                                                mainContext,
                                                MaterialPageRoute(
                                                    builder: ((context) =>
                                                        StudentProfile(
                                                            studentId: snapshot
                                                                .data
                                                                ?.docs[index]
                                                                .get('uid'),
                                                            studentName:
                                                                '${snapshot.data?.docs[index].get('firstName')} ${snapshot.data?.docs[index].get('secondName')}'))));
                                          */
                                          }),
                                      customButton(
                                          text: snapshot.data?.docs[index]
                                                  .get('isAdmin')
                                              ? 'Снять с администрирования'
                                              : 'Назначить администратором',
                                          color: Theme.of(mainContext)
                                              .bottomSheetTheme
                                              .backgroundColor!,
                                          textColor: Theme.of(mainContext)
                                              .textTheme
                                              .titleMedium!
                                              .color!
                                              .withOpacity(0.9),
                                          padding: const EdgeInsets.only(
                                              top: 15.0,
                                              left: 15.0,
                                              right: 15.0),
                                          onTap: () {
                                            FirebaseFirestore.instance
                                                .collection('classes')
                                                .doc(
                                                    appController.classId.value)
                                                .collection('members')
                                                .doc(snapshot.data?.docs[index]
                                                    .get('uid'))
                                                .update({
                                              'isAdmin': !(snapshot
                                                  .data?.docs[index]
                                                  .get('isAdmin') as bool)
                                            }).whenComplete(() {
                                              Get.back();
                                              dialog(
                                                  title: 'Уведомление',
                                                  content:
                                                      '${snapshot.data?.docs[index].get('firstName')} ${snapshot.data?.docs[index].get('secondName')} ${snapshot.data?.docs[index].get('isAdmin') as bool ? 'снят(а) с администрирования!' : 'назначен(а) администратором!'}');
                                            });
                                          }),
                                      customButton(
                                          text: 'Исключить ученика',
                                          color: Colors.redAccent,
                                          padding: const EdgeInsets.only(
                                              top: 15.0,
                                              left: 15.0,
                                              right: 15.0),
                                          onTap: () async {
                                            FirebaseFirestore.instance
                                                .collection('classes')
                                                .doc(
                                                    appController.classId.value)
                                                .collection('members')
                                                .doc(snapshot.data?.docs[index]
                                                    .get('uid'))
                                                .update({'exiled': true});

                                            Get.back();
                                          }),
                                    ],
                                  ),
                                ));
                              },
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Theme.of(mainContext)
                                        .bottomSheetTheme
                                        .backgroundColor!,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 30,
                                  color: Theme.of(mainContext)
                                      .textTheme
                                      .titleSmall!
                                      .color!
                                      .withOpacity(0.4),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    '${snapshot.data?.docs[index].get('firstName')} ${snapshot.data?.docs[index].get('secondName')}',
                                    textAlign: TextAlign.left,
                                    style: Theme.of(mainContext)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  FirebaseAuth.instance.currentUser!.uid ==
                                          snapshot.data?.docs[index].get('uid')
                                      ? Container(
                                          margin:
                                              const EdgeInsets.only(left: 5.0),
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 10,
                                                    color: Colors.redAccent
                                                        .withOpacity(0.8),
                                                    blurStyle: BlurStyle.normal)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.redAccent),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Вы',
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.roboto(
                                                  textStyle: const TextStyle(
                                                letterSpacing: 0.5,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              )),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  FirebaseAuth.instance.currentUser!.uid !=
                                              snapshot.data?.docs[index]
                                                  .get('uid') &&
                                          snapshot.data?.docs[index]
                                              .get('isAdmin') as bool
                                      ? Container(
                                          margin:
                                              const EdgeInsets.only(left: 5.0),
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 10,
                                                    color: Colors.purpleAccent
                                                        .withOpacity(0.8),
                                                    blurStyle: BlurStyle.normal)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.purpleAccent),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Админ',
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.roboto(
                                                  textStyle: const TextStyle(
                                                letterSpacing: 0.5,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              )),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              subtitle: Text(
                                getUserStatus(
                                    snapshot.data?.docs[index].get('status')),
                                textAlign: TextAlign.left,
                                style: Theme.of(mainContext)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: snapshot.data?.docs[index]
                                                  .get('status') ==
                                              'online'
                                          ? Colors.green
                                          : Theme.of(mainContext)
                                              .textTheme
                                              .titleSmall!
                                              .color!
                                              .withOpacity(0.7),
                                    ),
                              ),
                            );
                          });
                    }),
              ),
      ),
    );
  }
}
