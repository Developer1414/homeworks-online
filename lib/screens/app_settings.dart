import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/themes/my_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  final AppController appController = Get.put(AppController());

  @override
  Widget build(BuildContext mainContext) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Theme.of(mainContext).backgroundColor,
          appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: IconButton(
                  padding: const EdgeInsets.all(0.0),
                  splashRadius: 25.0,
                  onPressed: () => Navigator.pop(mainContext), //Get.back(),
                  icon: Icon(Icons.arrow_back_rounded,
                      color: Theme.of(mainContext).iconTheme.color, size: 35)),
            ),
            title: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: AutoSizeText(
                'Настройки приложения',
                maxLines: 1,
                textAlign: TextAlign.left,
                style: Theme.of(mainContext).textTheme.displayLarge,
              ),
            ),
          ),
          body: ListView(children: [
            Container(
              margin:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(mainContext)
                          .bottomSheetTheme
                          .backgroundColor!,
                      width: 2.5),
                  borderRadius: BorderRadius.circular(15.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, bottom: 15.0, left: 15.0),
                    child: AutoSizeText(
                      'Тёмная тема:',
                      maxLines: 2,
                      style: Theme.of(mainContext)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: Theme.of(mainContext)
                                  .textTheme
                                  .titleSmall!
                                  .color!
                                  .withOpacity(0.8)),
                    ),
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
                      value: appController.isDarkMode.value,
                      borderRadius: 30.0,
                      padding: 6.0,
                      onToggle: (isChanged) async {
                        final themeProvider =
                            Provider.of<ThemeClass>(mainContext, listen: false);

                        isChanged
                            ? themeProvider.setDarkMode()
                            : themeProvider.setLightMode();

                        Get.changeTheme(themeProvider.currentTheme!);

                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();

                        sharedPreferences.setBool('darkTheme', isChanged);

                        setState(() {
                          appController.isDarkMode.value = isChanged;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ])),
    );
  }
}
