import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/custom_button.dart';
import 'package:scool_home_working/models/dialog.dart';
import 'package:scool_home_working/screens/exiled_students.dart';
import 'package:scool_home_working/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassSettings extends StatefulWidget {
  const ClassSettings({super.key});

  static TextEditingController classPasswordController =
      TextEditingController();

  @override
  State<ClassSettings> createState() => _ClassSettingsState();
}

class _ClassSettingsState extends State<ClassSettings> {
  final AppController appController = Get.find();

  RxBool isLoading = false.obs;
  RxBool isAccessShowData = true.obs;

  Future getClassInfo() async {
    isLoading.value = true;

    await FirebaseFirestore.instance
        .collection('classes')
        .doc(appController.classId.value)
        .get()
        .then((value) {
      ClassSettings.classPasswordController.text = value.get('password');
    });

    isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();

    getClassInfo();
  }

  @override
  Widget build(BuildContext mainContext) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(mainContext);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
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
                    bottomNavigationBar: appController.teacherId.value ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? Row(
                            children: [
                              Expanded(
                                  child: customButton(
                                      borderRadius: 15.0,
                                      padding: const EdgeInsets.all(15.0),
                                      onTap: () async {
                                        isLoading.value = true;

                                        await FirebaseFirestore.instance
                                            .collection('classes')
                                            .doc(appController.classId.value)
                                            .update({
                                          'password': ClassSettings
                                              .classPasswordController.text,
                                        });

                                        isLoading.value = false;

                                        dialog(
                                            title: 'Уведомление',
                                            content: 'Изменения применены!');
                                      },
                                      text: 'Применить изменения',
                                      color: Colors.orange)),
                            ],
                          )
                        : null,
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
                          'Настройки класса',
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          style: Theme.of(mainContext).textTheme.displayLarge,
                        ),
                      ),
                    ),
                    body: ListView(children: [
                      ListTile(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: appController.classId.value));
                          dialog(
                              title: 'Уведомление', content: 'Код скопирован!');
                        },
                        title: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Код класса:',
                            style: Theme.of(mainContext)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(mainContext)
                                        .textTheme
                                        .titleSmall!
                                        .color!
                                        .withOpacity(0.7)),
                          ),
                        ),
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(top: 0.0, bottom: 10.0),
                          child: AutoSizeText(
                            appController.classId.value,
                            maxLines: 1,
                            style: Theme.of(mainContext).textTheme.titleMedium,
                          ),
                        ),
                        trailing: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            splashRadius: 28.0,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: appController.classId.value));
                              dialog(
                                  title: 'Уведомление',
                                  content: 'Код скопирован!');
                            },
                            icon: Icon(
                              Icons.copy_rounded,
                              color: Theme.of(mainContext).iconTheme.color,
                              size: 35,
                            )),
                      ),
                      appController.teacherId.value ==
                              FirebaseAuth.instance.currentUser!.uid
                          ? ListTile(
                              subtitle: TextField(
                                readOnly: isLoading.value,
                                controller:
                                    ClassSettings.classPasswordController,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                    labelText: 'Пароль класса...',
                                    labelStyle: Theme.of(mainContext)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                            color: Theme.of(mainContext)
                                                .textTheme
                                                .titleSmall!
                                                .color!
                                                .withOpacity(0.5)),
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
                                                .copyWith(backgroundColor: Theme.of(mainContext).textTheme.titleSmall!.color!.withOpacity(0.4))
                                                .backgroundColor!))),
                                style:
                                    Theme.of(mainContext).textTheme.titleMedium,
                              ),
                              trailing: IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  splashRadius: 28.0,
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text: ClassSettings
                                            .classPasswordController.text));
                                    dialog(
                                        title: 'Уведомление',
                                        content: 'Пароль скопирован!');
                                  },
                                  icon: Icon(
                                    Icons.copy_rounded,
                                    color:
                                        Theme.of(mainContext).iconTheme.color,
                                    size: 35,
                                  )),
                            )
                          : Container(),
                      customButton(
                          text: 'Выйти из класса',
                          color: Colors.redAccent,
                          borderRadius: 15.0,
                          padding: const EdgeInsets.only(
                              top: 15.0, left: 15.0, right: 15.0),
                          onTap: () async {
                            isLoading.value = true;

                            SharedPreferences pref =
                                await SharedPreferences.getInstance();

                            pref.remove('myClassId');

                            String tempClassId = appController.classId.value;

                            appController.classId.value = '';
                            appController.isAdmin.value = false;

                            await FirebaseFirestore.instance
                                .collection('classes')
                                .doc(tempClassId)
                                .collection('members')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({'status': DateTime.now().toString()});

                            isLoading.value = false;

                            // ignore: use_build_context_synchronously
                            Navigator.pushAndRemoveUntil(
                                mainContext,
                                MaterialPageRoute(
                                    builder: ((context) => const Login())),
                                (Route<dynamic> route) => false);
                          }),
                      appController.teacherId.value ==
                              FirebaseAuth.instance.currentUser!.uid
                          ? customButton(
                              text: 'Исключённые ученики',
                              color: Theme.of(mainContext)
                                  .bottomSheetTheme
                                  .backgroundColor!,
                              textColor: Theme.of(mainContext)
                                  .textTheme
                                  .titleMedium!
                                  .color!
                                  .withOpacity(0.9),
                              borderRadius: 15.0,
                              padding: const EdgeInsets.only(
                                  top: 15.0, left: 15.0, right: 15.0),
                              onTap: () async {
                                Navigator.push(
                                    mainContext,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const ExiledStudents())));
                              })
                          : Container(),
                    ])),
          )),
    );
  }
}
