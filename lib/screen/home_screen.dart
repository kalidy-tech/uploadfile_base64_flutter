import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uploadfile_base64_fltter/controller/home_controller.dart';

import '../widgets/custom_upload_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          'Upload File and Photo',
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: GetBuilder(
        init: homeController,
        id: "home",
        builder: (conext) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                TextButton(
                  onPressed: () => homeController.handleUpload(context),
                  child: const Text("Upload File"),
                ),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: homeController.filesList.length,
                  itemBuilder: (context, idx) {
                    return CustomCardUploadFile(
                      onTap: () => homeController.removeItem(idx),
                      index: idx,
                      name: homeController.getFileName(
                        homeController.filesList[idx],
                      ),
                      icon: homeController.checkTypeFile(
                        homeController.filesList[idx],
                      ),
                      size: homeController.getFileSize(
                        homeController.filesList[idx],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 5,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () => homeController.handleSubmit(),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(0),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 50,
                constraints:
                    const BoxConstraints(minWidth: 88.0, minHeight: 36.0),
                alignment: Alignment.center,
                child: const Text(
                  "Submit",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
