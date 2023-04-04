import 'package:get/get.dart';
import 'package:scool_home_working/models/task_model.dart';

class AppController extends GetxController {
  RxInt currentScreen = 0.obs;

  RxString classId = ''.obs;
  RxString teacherId = ''.obs;
  RxString firstName = ''.obs;
  RxString secondName = ''.obs;

  RxBool isAdmin = false.obs;
  RxBool isDarkMode = false.obs;

  RxList<Task> selectedTasks = <Task>[].obs;
  RxList<Task> tasks = <Task>[].obs;

  RxList<String> admins = <String>[].obs;
}
