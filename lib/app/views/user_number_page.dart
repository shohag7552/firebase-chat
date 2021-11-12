import 'package:flutter/material.dart';
import 'package:flutter_chat/app/controllers/user_number_controller.dart';
import 'package:get/get.dart';

class NumberInputPage extends StatelessWidget {
  NumberInputPage({Key? key}) : super(key: key);

  final UserNumberController controller = Get.put(UserNumberController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: 'type your number'),
                  controller: controller.yourphoneController,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: 'type partner\'s number'),
                  controller: controller.hisphoneController,
                ),
              ),
              const Spacer(
                flex: 3,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(
                    '/chat',
                    arguments: {
                      'first': controller.yourphoneController.text,
                      'second': controller.hisphoneController.text,
                    },
                  );
                },
                child: const Text('Go to chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
