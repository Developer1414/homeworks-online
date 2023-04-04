import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/custom_button.dart';
import 'package:scool_home_working/screens/new_task.dart';

class TaskSettings extends StatelessWidget {
  const TaskSettings({super.key, this.taskId = ''});

  final String taskId;

  @override
  Widget build(BuildContext mainContext) {
    final AppController appController = Get.find();

    RxBool isLoading = false.obs;
    RxBool isAccessShowData = true.obs;

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
                  bottomNavigationBar: Row(
                    children: [
                      Expanded(
                          child: customButton(
                              borderRadius: 15.0,
                              padding: const EdgeInsets.only(
                                  left: 15.0, bottom: 15.0, top: 15.0),
                              onTap: () {
                                /*Get.back();
                                Get.to(() => NewTask(taskIdForChange: taskId));*/

                                Navigator.push(
                                    mainContext,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            NewTask(taskIdForChange: taskId))));
                              },
                              text: 'Изменить',
                              color: Colors.orange)),
                      const SizedBox(width: 15.0),
                      Expanded(
                          child: customButton(
                              borderRadius: 15.0,
                              padding: const EdgeInsets.only(
                                  right: 15.0, bottom: 15.0, top: 15.0),
                              onTap: () async {
                                isLoading.value = true;
                                await FirebaseFirestore.instance
                                    .collection('classes')
                                    .doc(appController.classId.value)
                                    .collection('homeworks')
                                    .doc(taskId)
                                    .delete()
                                    .whenComplete(() {
                                  isLoading.value = false;
                                  isAccessShowData.value = false;

                                  Navigator.of(mainContext).pop();
                                });
                              },
                              text: 'Удалить',
                              color: Colors.red)),
                    ],
                  ),
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
                        'Настройки задания',
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: Theme.of(mainContext).textTheme.displayLarge,
                      ),
                    ),
                  ),
                  body: !isAccessShowData.value
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('classes')
                                  .doc(appController.classId.value)
                                  .collection('homeworks')
                                  .doc(taskId)
                                  .get(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: LoadingIndicator(
                                        size: 55.0, borderWidth: 3.5),
                                  );
                                }

                                return ListView(children: [
                                  ListTile(
                                    title: Text(
                                      'Предмет:',
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
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 10.0),
                                      child: Text(
                                        snapshot.data!.get('taskName'),
                                        style: Theme.of(mainContext)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Задание:',
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
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 10.0),
                                      child: Text(
                                        snapshot.data!.get('task'),
                                        style: Theme.of(mainContext)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Задано на:',
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
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 10.0),
                                      child: Text(
                                        DateFormat.MMMMd('ru_RU').format(
                                            (snapshot.data!.get('date')
                                                    as Timestamp)
                                                .toDate()),
                                        style: Theme.of(mainContext)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Важное задание:',
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
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 10.0),
                                      child: Text(
                                        snapshot.data!.get('important')
                                                    as bool ==
                                                true
                                            ? 'Да'
                                            : 'Нет',
                                        style: Theme.of(mainContext)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Создано:',
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
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 10.0),
                                      child: Text(
                                        DateFormat.yMd('ru_RU').add_jm().format(
                                            (snapshot.data!.get('createDate')
                                                    as Timestamp)
                                                .toDate()),
                                        style: Theme.of(mainContext)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                ]);
                              }))),
        ));
  }
}
