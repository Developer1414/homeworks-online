import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/custom_button.dart';
import 'package:scool_home_working/models/dialog.dart';

class ExiledStudents extends StatelessWidget {
  const ExiledStudents({super.key});

  @override
  Widget build(BuildContext mainContext) {
    final AppController appController = Get.find();

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
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
                padding: const EdgeInsets.all(0.0),
                splashRadius: 25.0,
                onPressed: () => Navigator.pop(mainContext),
                icon: Icon(Icons.arrow_back_rounded,
                    color: Theme.of(mainContext).iconTheme.color, size: 35)),
          ),
          toolbarHeight: 100,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                'Исключённые ученики',
                maxLines: 1,
                textAlign: TextAlign.left,
                style: Theme.of(mainContext).textTheme.displayLarge,
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .doc(appController.classId.value)
                  .collection('members')
                  .where('exiled', isEqualTo: true)
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
                            'Исключённых учеников нет',
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
                        itemCount: snapshot.data?.docs.length ?? 0,
                        separatorBuilder: (ctx, index) =>
                            const SizedBox(height: 5.0),
                        itemBuilder: (ctx, index) {
                          return ListTile(
                            onTap: () async {
                              await Get.bottomSheet(Container(
                                height: 112.0,
                                margin: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(mainContext).backgroundColor,
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 8.0,
                                      width: 70.0,
                                      margin: const EdgeInsets.only(top: 15.0),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade700,
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                    ),
                                    customButton(
                                        text: 'Вернуть ученика',
                                        color: Colors.green,
                                        textColor: Colors.white,
                                        padding: const EdgeInsets.only(
                                            top: 15.0, left: 15.0, right: 15.0),
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('classes')
                                              .doc(appController.classId.value)
                                              .collection('members')
                                              .doc(snapshot.data?.docs[index]
                                                  .get('uid'))
                                              .update({'exiled': false});

                                          Get.back();
                                          dialog(
                                              title: 'Уведомление',
                                              content:
                                                  '${snapshot.data?.docs[index].get('firstName')} ${snapshot.data?.docs[index].get('secondName')} снова в классе!');
                                        }),
                                    /*customButton(
                                        text: 'Полностью удалить',
                                        color: Colors.redAccent,
                                        padding: const EdgeInsets.only(
                                            top: 15.0, left: 15.0, right: 15.0),
                                        onTap: () async {
                                          FirebaseFirestore.instance
                                              .collection('classes')
                                              .doc(appController.classId.value)
                                              .collection('members')
                                              .doc(snapshot.data?.docs[index]
                                                  .get('uid'))
                                              .update({'exiled': true});

                                          Get.back();
                                        }),*/
                                  ],
                                ),
                              ));
                            },
                            leading: const CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                    'https://upload.wikimedia.org/wikipedia/commons/9/9a/Gull_portrait_ca_usa.jpg')),
                            title: Row(
                              children: [
                                Text(
                                  '${snapshot.data?.docs[index].get('firstName')} ${snapshot.data?.docs[index].get('secondName')}',
                                  textAlign: TextAlign.left,
                                  style: Theme.of(mainContext)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ],
                            ),
                          );
                        });
              }),
        ),
      ),
    );
  }
}
