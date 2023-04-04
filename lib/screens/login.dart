import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/main.dart';
import 'package:scool_home_working/models/custom_button.dart';
import 'package:scool_home_working/models/dialog.dart';
import 'package:scool_home_working/screens/login_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  static TextEditingController classIdController = TextEditingController();
  static TextEditingController firstNameController = TextEditingController();
  static TextEditingController secondNameController = TextEditingController();
  static TextEditingController classPasswordController =
      TextEditingController();

  static RxBool isStudent = true.obs;

  @override
  Widget build(BuildContext mainContext) {
    RxBool isLoading = false.obs;

    final AppController appController = Get.put(AppController());

    Widget customTextField(String hintText, TextEditingController controller,
        [bool isLast = false]) {
      return TextField(
        readOnly: isLoading.value,
        controller: controller,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(mainContext).textTheme.titleSmall!.copyWith(
                  color: Theme.of(mainContext)
                      .textTheme
                      .titleSmall!
                      .color!
                      .withOpacity(0.5),
                ),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(mainContext)
                        .bottomSheetTheme
                        .copyWith(
                            backgroundColor: Theme.of(mainContext)
                                .textTheme
                                .titleSmall!
                                .color!
                                .withOpacity(0.4))
                        .backgroundColor!)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(mainContext)
                        .bottomSheetTheme
                        .copyWith(
                            backgroundColor: Theme.of(mainContext)
                                .textTheme
                                .titleSmall!
                                .color!)
                        .backgroundColor!))),
        style: Theme.of(mainContext).textTheme.titleSmall!,
      );
    }

    bool checkInputFieldsOnEmpty() {
      if (isStudent.value) {
        if (classIdController.text.isEmpty) {
          dialog(
              title: 'Ошибка',
              content: 'Вы не вписали код класса.',
              isError: true);
          return false;
        }
      }

      if (isStudent.value) {
        if (classPasswordController.text.isEmpty) {
          dialog(
              title: 'Ошибка',
              content: 'Вы не вписали пароль класса.',
              isError: true);
          return false;
        }
      }

      if (firstNameController.text.isEmpty) {
        dialog(
            title: 'Ошибка', content: 'Вы не вписали Ваше имя.', isError: true);
        return false;
      }

      if (secondNameController.text.isEmpty) {
        dialog(
            title: 'Ошибка',
            content: 'Вы не вписали Вашу фамилию.',
            isError: true);
        return false;
      }

      return true;
    }

    Future loginLikeStudent() async {
      if (!checkInputFieldsOnEmpty()) return;

      isLoading.value = true;

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classIdController.text.trim())
          .get()
          .then((value) async {
        if (!value.exists) {
          isLoading.value = false;
          dialog(
              title: 'Ошибка',
              content: 'Класса с таким кодом не существует!',
              isError: true);
          return;
        } else {
          if (value.get('password') != classPasswordController.text) {
            isLoading.value = false;
            dialog(
                title: 'Ошибка',
                content: 'Неверный пароль класса!',
                isError: true);
            return;
          } else {
            await FirebaseFirestore.instance
                .collection('classes')
                .doc(classIdController.text.trim())
                .collection('members')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((value) async {
              if (value.exists) {
                await FirebaseFirestore.instance
                    .collection('classes')
                    .doc(classIdController.text.trim())
                    .collection('members')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get()
                    .then((value) async {
                  if (value.get('exiled') as bool == true) {
                    isLoading.value = false;
                    dialog(
                        title: 'Ошибка',
                        content: 'Вас исключили из этого класса!',
                        isError: true);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('classes')
                        .doc(classIdController.text.trim())
                        .collection('members')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({'status': 'online'});

                    isLoading.value = false;

                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setString('myClassId', classIdController.text.trim());
                    appController.classId.value = classIdController.text.trim();

                    //Get.off(() => const MyApp());

                    // ignore: use_build_context_synchronously
                    Navigator.pushAndRemoveUntil(
                        mainContext,
                        MaterialPageRoute(
                            builder: ((context) => const MyApp())),
                        (Route<dynamic> route) => false);
                  }
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('classes')
                    .doc(classIdController.text.trim())
                    .collection('members')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .set({
                  'firstName': firstNameController.text,
                  'secondName': secondNameController.text,
                  'uid': FirebaseAuth.instance.currentUser!.uid,
                  'status': 'online',
                  'exiled': false,
                  'isAdmin': false,
                });

                isLoading.value = false;

                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setString('myClassId', classIdController.text.trim());
                appController.classId.value = classIdController.text.trim();

                Get.off(() => const MyApp());
              }
            });
          }
        }
      });
    }

    Future loginLikeTeacher() async {
      if (!checkInputFieldsOnEmpty()) return;

      isLoading.value = true;

      final newClass = FirebaseFirestore.instance.collection('classes').doc();

      await newClass.set({
        'teacherId': FirebaseAuth.instance.currentUser!.uid,
        'password': classPasswordController.text
      });

      await newClass
          .collection('members')
          .doc(FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : null)
          .set({
        'firstName': firstNameController.text,
        'secondName': secondNameController.text,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'status': 'online',
        'exiled': false,
        'isAdmin': true,
      });

      isLoading.value = false;
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('myClassId', newClass.id);
      appController.classId.value = newClass.id;
      //Get.off(() => const MyApp());

      Clipboard.setData(ClipboardData(
          text:
              'Код класса: ${appController.classId.value}\nПароль: ${classPasswordController.text}'));
      dialog(
          title: 'Уведомление',
          content:
              'Код и пароль класса скопированы в буфер обмена! Теперь Вам нужно отправить скопированный текст Вашим ученикам. Также, код и пароль класса Вы сможете увидеть в настройках класса!');

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          mainContext,
          MaterialPageRoute(builder: ((context) => const MyApp())),
          (Route<dynamic> route) => false);
    }

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
                  appBar: AppBar(
                    toolbarHeight: 100,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: AutoSizeText(
                        'Вход в класс',
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
                            splashRadius: 25.0,
                            onPressed: () => Navigator.push(
                                mainContext,
                                MaterialPageRoute(
                                    builder: ((context) =>
                                        const LoginToAccount()))), //Get.to(() => const LoginToAccount()),
                            icon: Icon(Icons.login_rounded,
                                color: Theme.of(mainContext).iconTheme.color,
                                size: 35)),
                      ),
                    ],
                  ),
                  body: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.only(
                                      left: 40.0, right: 40.0),
                                  decoration: BoxDecoration(
                                      color: Theme.of(mainContext)
                                          .bottomSheetTheme
                                          .backgroundColor!
                                          .withOpacity(0.7),
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: Obx(
                                    () => Row(
                                      children: [
                                        Expanded(
                                          child: customButton(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0,
                                                  top: 10.0,
                                                  bottom: 10.0),
                                              text: 'Ученик',
                                              textColor: isStudent.value
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                              color: isStudent.value
                                                  ? Colors.blueAccent
                                                  : Colors.grey
                                                      .withOpacity(0.9),
                                              onTap: () =>
                                                  isStudent.value = true,
                                              borderRadius: 15.0),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Expanded(
                                          child: customButton(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0,
                                                  top: 10.0,
                                                  bottom: 10.0),
                                              text: 'Учитель',
                                              textColor: isStudent.value
                                                  ? Colors.white
                                                      .withOpacity(0.8)
                                                  : Colors.white,
                                              color: isStudent.value
                                                  ? Colors.grey.withOpacity(0.9)
                                                  : Colors.blueAccent,
                                              onTap: () =>
                                                  isStudent.value = false,
                                              borderRadius: 15.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Obx(() => Container(
                                margin: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                    color: Theme.of(mainContext)
                                        .bottomSheetTheme
                                        .backgroundColor!
                                        .withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0, top: 15.0),
                                      child: customTextField(
                                          'Ваше имя...', firstNameController),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0, top: 15.0),
                                      child: customTextField('Ваша фамилия...',
                                          secondNameController),
                                    ),
                                    isStudent.value
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0,
                                                right: 15.0,
                                                top: 15.0),
                                            child: customTextField(
                                                'Код класса...',
                                                classIdController),
                                          )
                                        : Container(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0, top: 15.0),
                                      child: customTextField('Пароль класса...',
                                          classPasswordController, true),
                                    ),
                                    customButton(
                                        onTap: () async {
                                          if (isStudent.value) {
                                            await loginLikeStudent();
                                          } else {
                                            await loginLikeTeacher();
                                          }
                                        },
                                        text: isStudent.value
                                            ? 'Войти'
                                            : 'Создать класс',
                                        textSize: 25.0,
                                        color: Colors.green,
                                        padding: const EdgeInsets.all(15.0),
                                        borderRadius: 15.0),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
