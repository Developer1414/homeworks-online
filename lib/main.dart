import 'dart:io';

import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/dialog.dart';
import 'package:scool_home_working/screens/login.dart';
import 'package:scool_home_working/screens/login_account.dart';
import 'package:scool_home_working/screens/my_class.dart';
import 'package:scool_home_working/screens/new_task.dart';
import 'package:scool_home_working/screens/task_list.dart';
import 'package:scool_home_working/themes/my_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Appodeal.setAppKeys(
    androidAppKey: '175ef42897ba7a650c6cb4a11d01ad642217c1fc119d970a',
  );

  await Appodeal.initialize(
    hasConsent: true,
    adTypes: [
      AdType.mrec,
      AdType.interstitial,
    ],
    verbose: true,
  );

  if (Platform.isAndroid) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((value) {
      initializeDateFormatting('ru_RU', null).then((value) => runApp(
              MultiProvider(
                  providers: [
                ChangeNotifierProvider(
                  create: (_) => ThemeClass(),
                ),
              ],
                  child: const GetMaterialApp(
                      debugShowCheckedModeBanner: false, home: MyApp()))));
    });

    //await LocalNoticeService().setup();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static List<String> subjects = [
    'Алгебра',
    'Астрономия',
    'Биология',
    'География',
    'Геометрия',
    'Естествознание',
    'ИЗО',
    'Иностранный язык',
    'Информатика',
    'Истоки',
    'История',
    'Краеведение',
    'Литература',
    'Математика',
    'МХК',
    'Музыка',
    'Начальная военная подготовка',
    'Общественно-полезный труд',
    'Обществознание',
    'Окружающий мир',
    'ОБЖ',
    'Основы духовно-нравственных культур народов России',
    'Основы религиозных культур и светской этики',
    'Основы финансовой грамотности',
    'Основы экономики',
    'Проектирование',
    'Психотренинг',
    'Риторика',
    'Родная литература',
    'Родной язык',
    'Русский язык',
    'Статистика',
    'Технология',
    'Физика',
    'Физкультура',
    'Философия',
    'Химия',
    'Черчение',
    'Экология'
  ];

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RxBool isLoading = false.obs;

  final AppController appController = Get.put(AppController());

  List screens = [];
  List screensForAdmins = [const TaskList(), const MyClass(), const NewTask()];
  List screensForStudents = [const TaskList(), const MyClass()];

  Future<Widget?> checkMyClass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    bool isExiled = false;

    if (!pref.containsKey('myClassId')) {
      if (FirebaseAuth.instance.currentUser != null) {
        return const Login();
      } else {
        return const LoginToAccount();
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      appController.classId.value = pref.getString('myClassId').toString();

      isLoading.value = true;

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(appController.classId.value)
          .collection('members')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        if ((value.get('exiled') as bool) != true) {
          appController.firstName.value = value.get('firstName');
          appController.secondName.value = value.get('secondName');
          appController.isAdmin.value = value.get('isAdmin') as bool;

          screens = appController.isAdmin.value
              ? screensForAdmins
              : screensForStudents;
        } else {
          dialog(
              title: 'Ошибка',
              content: 'Вас исключили из класса!',
              isError: true);
          isExiled = true;
          pref.remove('myClassId');
        }
      });

      if (isExiled) {
        return const Login();
      }

      isLoading.value = false;

      FirebaseFirestore.instance
          .collection('classes')
          .doc(appController.classId.value)
          .get()
          .then((value) {
        appController.teacherId.value = value.get('teacherId');
      });
    }
  }

  Future loadTheme() async {
    final themeProvider = Provider.of<ThemeClass>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('darkTheme')) {
      prefs.getBool('darkTheme') as bool
          ? themeProvider.setDarkMode()
          : themeProvider.setLightMode();

      appController.isDarkMode.value = prefs.getBool('darkTheme') as bool;
    } else {
      themeProvider.setLightMode();
    }
  }

  @override
  void initState() {
    super.initState();
    screens = screensForStudents;
    loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: Provider.of<ThemeClass>(context).currentTheme,
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: checkMyClass(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: LoadingIndicator(size: 55.0, borderWidth: 3.5),
              );
            }

            return snapshot.data == null
                ? Obx(
                    () => isLoading.value
                        ? Scaffold(
                            backgroundColor: Theme.of(context).backgroundColor,
                            body: const Center(
                              child: LoadingIndicator(
                                  size: 55.0, borderWidth: 3.5),
                            ),
                          )
                        : Scaffold(
                            backgroundColor: Theme.of(context).backgroundColor,
                            bottomNavigationBar: Obx(
                              () => appController.isAdmin.value
                                  ? BottomNavigationBar(
                                      backgroundColor: Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .backgroundColor,
                                      elevation: 15,
                                      iconSize: 25,
                                      type: BottomNavigationBarType.fixed,
                                      currentIndex:
                                          appController.currentScreen.value,
                                      showSelectedLabels: false,
                                      showUnselectedLabels: false,
                                      items: const [
                                        BottomNavigationBarItem(
                                          icon: Icon(Icons.menu_rounded),
                                          activeIcon: Icon(Icons.menu_rounded),
                                          label: 'Мои задания',
                                          tooltip: '',
                                        ),
                                        BottomNavigationBarItem(
                                          icon: Icon(Icons.people_alt_outlined),
                                          activeIcon:
                                              Icon(Icons.people_alt_rounded),
                                          label: 'Мой класс',
                                          tooltip: '',
                                        ),
                                        BottomNavigationBarItem(
                                          icon: Icon(Icons.add_task_rounded),
                                          activeIcon:
                                              Icon(Icons.add_task_rounded),
                                          label: 'Новое ДЗ',
                                          tooltip: '',
                                        ),
                                      ],
                                      onTap: (index) {
                                        appController.currentScreen.value =
                                            index;
                                      },
                                    )
                                  : BottomNavigationBar(
                                      backgroundColor: Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .backgroundColor,
                                      elevation: 15,
                                      iconSize: 25,
                                      type: BottomNavigationBarType.fixed,
                                      currentIndex:
                                          appController.currentScreen.value,
                                      showSelectedLabels: false,
                                      showUnselectedLabels: false,
                                      items: const [
                                        BottomNavigationBarItem(
                                          icon: Icon(Icons.menu_rounded),
                                          activeIcon: Icon(Icons.menu_rounded),
                                          label: 'Мои задания',
                                          tooltip: '',
                                        ),
                                        BottomNavigationBarItem(
                                          icon: Icon(Icons.people_alt_outlined),
                                          activeIcon:
                                              Icon(Icons.people_alt_rounded),
                                          label: 'Мой класс',
                                          tooltip: '',
                                        ),
                                      ],
                                      onTap: (index) {
                                        appController.currentScreen.value =
                                            index;
                                      },
                                    ),
                            ),
                            body: Obx(() => screens
                                .elementAt(appController.currentScreen.value)),
                          ),
                  )
                : snapshot.data!;
          },
        ));
  }
}
