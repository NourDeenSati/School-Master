import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/controllers/auth/login_controller.dart';

class LoginView extends StatelessWidget {
  //bool _obscureText = true;
  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0.82, // يقلل المساحة المحجوزة للصورة
                      child: Transform.scale(
                        scale: 1.2,
                        child: Image.asset(
                          'assets/images/School Master22.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'School Master',
                      style: TextStyle(color: Color(0xFF4B70F5), fontSize: 25),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: Get.locale?.languageCode == 'ar'
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Text(
                          'do sinin please'.tr,
                          style:
                              TextStyle(color: Color(0xFF4B70F5), fontSize: 30),
                        ),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9.0),
                child: TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Color(0xFF4B70F5)),
                    labelText: 'userName'.tr,
                    prefixIcon:
                        // تحديد عرض ثابت للمساحة
                        //alignment: Alignment.center,
                        Icon(
                      Icons.supervised_user_circle,
                      size: 40,
                      color: Color(0xFF4B70F5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF4B70F5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4B70F5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusColor: Color(0xFF4B70F5),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GetBuilder<LoginController>(
                builder: (controller) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  child: TextField(
                    obscureText: controller.obscureText,
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Color(0xFF4B70F5)),
                      labelText: 'password'.tr,
                      suffixIcon: IconButton(
                          onPressed: () {
                            controller.togglePasswordVisibility();
                          },
                          icon: Icon(controller.obscureText == false
                              ? Icons.visibility
                              : Icons.visibility_off)),
                      prefixIcon:
                          // تحديد عرض ثابت للمساحة
                          //alignment: Alignment.center,
                          Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Color(0xFF4B70F5)),
                          child: Icon(
                            Icons.lock_person_outlined,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(0xFF4B70F5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4B70F5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusColor: Color(0xFF4B70F5),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.login,
                child: Text('login'.tr),
              ),
            ])));
  }
}
