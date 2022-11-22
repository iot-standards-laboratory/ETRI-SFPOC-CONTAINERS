import 'package:flutter/material.dart';
import 'package:front/app/modules/home/config/responsive.dart';
import 'package:front/constants.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  Widget renderBody(BuildContext context, {required double maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          children: [
            const Icon(Icons.android, size: 120),
            if (!Responsive.isMobile(context)) const SizedBox(height: 10),
            Text(
              'Etri Smart Farm',
              style: GoogleFonts.bebasNeue(
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome our smart farm service!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Email",
                      border: InputBorder.none,
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return '이메일은 필수사항입니다.';
                      }
                      if (!RegExp(
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                          .hasMatch(val)) {
                        return '잘못된 이메일 형식입니다.';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      if (val != null) {
                        controller.email = val;
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                    ),
                    onSaved: (val) {
                      if (val != null) {
                        controller.password = val;
                      }
                    },
                    validator: (val) {
                      if (val!.isEmpty) {
                        return '비밀번호는 필수사항입니다.';
                      }

                      if (val.length < 8) {
                        return '8자 이상 입력해주세요!';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                onPressed: () async {
                  if (controller.formKey.currentState!.validate()) {
                    controller.formKey.currentState!.save();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          content: Center(
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: LoadingIndicator(
                                indicatorType:
                                    Indicator.ballTrianglePathColoredFilled,
                                colors: kDefaultRainbowColors,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                    var result = await controller.login();
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pop(context, true);
                      if (result) {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Get.offAllNamed("/controller");
                        });

                        Future.delayed(const Duration(milliseconds: 800), () {
                          Get.snackbar(
                              "Success", "welcome to smart farm service");
                        });
                        return;
                      }

                      Get.snackbar("Failed", "login process is failed");
                    });
                  }
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Not a member?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  customBorder: const StadiumBorder(),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    child: Text(
                      ' Register Now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (ctx, ctis) {
          return Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    child: ctis.maxWidth >= 700
                        ? renderBody(context, maxWidth: 700)
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: renderBody(context, maxWidth: ctis.maxWidth),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
