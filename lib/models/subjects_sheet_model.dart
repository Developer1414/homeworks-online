import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scool_home_working/main.dart';

Future modalBottomSheetSubjects(
    BuildContext mainContext, TextEditingController controller) async {
  await Get.bottomSheet(Container(
    height: 500.0,
    margin: const EdgeInsets.all(15.0),
    decoration: BoxDecoration(
        color: Theme.of(mainContext).backgroundColor,
        borderRadius: BorderRadius.circular(15.0)),
    child: Column(
      children: [
        Container(
          height: 8.0,
          width: 70.0,
          margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(20.0)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: MyApp.subjects.length,
              itemBuilder: (ctx, index) {
                return Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: index % 2 != 0
                          ? Colors.transparent
                          : Theme.of(mainContext)
                              .bottomSheetTheme
                              .backgroundColor!
                              .withOpacity(0.4)),
                  child: ListTile(
                    onTap: () {
                      controller.text = MyApp.subjects[index];
                      Get.back();
                    },
                    title: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(MyApp.subjects[index],
                          style: GoogleFonts.roboto(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(mainContext)
                                  .textTheme
                                  .titleMedium!
                                  .color!
                                  .withOpacity(0.8))),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  ));
}
