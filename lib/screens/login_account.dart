import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scool_home_working/controllers/app_controller.dart';
import 'package:scool_home_working/models/custom_button.dart';
import 'package:scool_home_working/models/dialog.dart';
import 'package:scool_home_working/screens/login.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginToAccount extends StatelessWidget {
  const LoginToAccount({super.key});

  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();

  static RxBool isSignIn = true.obs;

  @override
  Widget build(BuildContext mainContext) {
    RxBool isLoading = false.obs;

    final AppController appController = Get.put(AppController());

    bool checkInputFieldsOnEmpty() {
      if (passwordController.text.isEmpty) {
        dialog(
            title: 'Ошибка',
            content: 'Вы не вписали Вашу почту.',
            isError: true);
        return false;
      }

      if (passwordController.text.isEmpty) {
        dialog(
            title: 'Ошибка',
            content: 'Вы не вписали Ваш пароль.',
            isError: true);
        return false;
      }

      return true;
    }

    Future createAccount() async {
      if (!checkInputFieldsOnEmpty()) return;

      isLoading.value = true;

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        isLoading.value = false;

        // ignore: use_build_context_synchronously
        Navigator.push(mainContext,
            MaterialPageRoute(builder: ((context) => const Login())));

        //Get.off(() => const Login());
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;

        if (e.code == 'weak-password') {
          dialog(
              title: 'Ошибка',
              content: 'Предоставленный пароль слишком слаб.',
              isError: true);
        } else if (e.code == 'email-already-in-use') {
          dialog(
              title: 'Ошибка',
              content: 'Данный адрес электронной почты уже существует.',
              isError: true);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    Future signInAccount() async {
      if (!checkInputFieldsOnEmpty()) return;

      isLoading.value = true;

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text);

        isLoading.value = false;

        // ignore: use_build_context_synchronously
        Navigator.push(mainContext,
            MaterialPageRoute(builder: ((context) => const Login())));

        //Get.off(() => const Login());
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;

        if (e.code == 'user-not-found') {
          dialog(
              title: 'Ошибка',
              content:
                  'Пользователь с данным адресом электронной почты не найден!',
              isError: true);
        } else if (e.code == 'wrong-password') {
          dialog(
              title: 'Ошибка',
              content: 'Указан неверный пароль!',
              isError: true);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
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
                        'Вход в аккаунт',
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        style: Theme.of(mainContext).textTheme.displayLarge,
                      ),
                    ),
                    actions: [
                      FirebaseAuth.instance.currentUser != null
                          ? Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  splashRadius: 25.0,
                                  onPressed: () =>
                                      Navigator.pop(mainContext), //Get.back(),
                                  icon: Icon(Icons.close_rounded,
                                      color:
                                          Theme.of(mainContext).iconTheme.color,
                                      size: 35)),
                            )
                          : Container(),
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
                                              text: 'Вход',
                                              textColor: isSignIn.value
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                              color: isSignIn.value
                                                  ? Colors.blueAccent
                                                  : Colors.grey
                                                      .withOpacity(0.9),
                                              onTap: () =>
                                                  isSignIn.value = true,
                                              borderRadius: 15.0),
                                        ),
                                        const SizedBox(width: 10.0),
                                        Expanded(
                                          child: customButton(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0,
                                                  top: 10.0,
                                                  bottom: 10.0),
                                              text: 'Регистрация',
                                              textColor: isSignIn.value
                                                  ? Colors.white
                                                      .withOpacity(0.8)
                                                  : Colors.white,
                                              color: isSignIn.value
                                                  ? Colors.grey.withOpacity(0.9)
                                                  : Colors.blueAccent,
                                              onTap: () =>
                                                  isSignIn.value = false,
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
                                      child: TextField(
                                        readOnly: isLoading.value,
                                        controller: emailController,
                                        textInputAction: TextInputAction.next,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          hintText: 'Ваша почта...',
                                          hintStyle: Theme.of(mainContext)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
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
                                                          backgroundColor: Theme
                                                                  .of(mainContext)
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
                                                          backgroundColor:
                                                              Theme.of(
                                                                      mainContext)
                                                                  .textTheme
                                                                  .titleSmall!
                                                                  .color!)
                                                      .backgroundColor!)),
                                        ),
                                        style: Theme.of(mainContext)
                                            .textTheme
                                            .titleSmall!,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, right: 15.0, top: 15.0),
                                      child: TextField(
                                        readOnly: isLoading.value,
                                        controller: passwordController,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          hintText: 'Ваш пароль...',
                                          hintStyle: Theme.of(mainContext)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
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
                                                          backgroundColor: Theme
                                                                  .of(mainContext)
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
                                                          backgroundColor:
                                                              Theme.of(
                                                                      mainContext)
                                                                  .textTheme
                                                                  .titleSmall!
                                                                  .color!)
                                                      .backgroundColor!)),
                                        ),
                                        style: Theme.of(mainContext)
                                            .textTheme
                                            .titleSmall!,
                                      ),
                                    ),
                                    customButton(
                                        onTap: () async {
                                          if (!isSignIn.value) {
                                            await createAccount();
                                          } else {
                                            await signInAccount();
                                          }
                                        },
                                        text: !isSignIn.value
                                            ? 'Зарегистрироваться'
                                            : 'Войти',
                                        textSize: 25.0,
                                        color: Colors.green,
                                        padding: const EdgeInsets.all(15.0),
                                        borderRadius: 15.0),
                                    !isSignIn.value
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0,
                                                right: 15.0,
                                                bottom: 15.0),
                                            child: RichText(
                                                textAlign: TextAlign.center,
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text:
                                                        'Регистрируясь, Вы соглашаетесь с нашей ',
                                                    style: GoogleFonts.roboto(
                                                        textStyle: Theme.of(
                                                                mainContext)
                                                            .textTheme
                                                            .titleSmall!
                                                            .copyWith(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        mainContext)
                                                                    .textTheme
                                                                    .titleSmall!
                                                                    .color!
                                                                    .withOpacity(
                                                                        0.8))),
                                                  ),
                                                  TextSpan(
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            var url = Uri.parse(
                                                                "https://drive.google.com/file/d/1Cfp7LznMhvzlZdusa2WkR-TvNY8UPTxz/view?usp=share_link");
                                                            if (await canLaunchUrl(
                                                                url)) {
                                                              await launchUrl(
                                                                  url);
                                                            } else {
                                                              throw "Could not launch $url";
                                                            }
                                                          },
                                                    text:
                                                        'Политикой Конфиденциальности',
                                                    style: GoogleFonts.roboto(
                                                        textStyle:
                                                            const TextStyle(
                                                      letterSpacing: 0.5,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.blue,
                                                    )),
                                                  )
                                                ])),
                                            /*AutoSizeText(
                                                'Регистрируясь, Вы принимаете нашу Политику Конфиденциальности',
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(mainContext)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: Theme.of(
                                                                mainContext)
                                                            .textTheme
                                                            .titleSmall!
                                                            .color!
                                                            .withOpacity(0.6))),*/
                                          )
                                        : Container(),
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
