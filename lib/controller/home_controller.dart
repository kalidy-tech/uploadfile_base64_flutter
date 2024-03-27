import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/file_model/file_model.dart';

class HomeController extends GetxController {
  List<File> filesList = [];
  FilePickerResult? result;

  handleSubmit() async {
    var fileList = <FilesModel>[];
    debugPrint("--------File Before Convert $filesList");
    await Future.wait(filesList.asMap().entries.map((element) async {
      var base64String = await getBase64(element.value);
      fileList.add(
        FilesModel(
          filename: getFileName(element.value),
          fileContent: base64String,
        ),
      );
    }).toList());
    // Here is FileList base64
    debugPrint("--------After  Convert ${fileList.map((e) => e.fileContent)}");

    //Now you can submit list of base64 to api
  }

  handleUpload(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text("Option"),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text("Upload File"),
              onPressed: () {
                uploadFile();
                Navigator.pop(context);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text("Gallery"),
              onPressed: () {
                uploadPhoto();
                Navigator.pop(context);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void removeItem(int index) {
    filesList.removeAt(index);
    update(['home']);
  }

  String getFileName(File file) {
    var filename = file.path.split("/");
    return filename[filename.length - 1];
  }

  String getFileSize(File file) {
    var fileSizeInBytes = file.lengthSync();

    // Convert bytes to kilobytes
    var fileSizeInKB = fileSizeInBytes / 1024;

    if (fileSizeInKB > 1000) {
      // Convert kilobytes to megabytes and return as a string
      var fileSizeInMB = fileSizeInKB / 1024;
      return '${fileSizeInMB.toStringAsFixed(2)} MB';
    } else {
      return '${fileSizeInKB.toStringAsFixed(2)} KB';
    }
  }

  String? getContentType(String filePath) {
    // Determine file extension
    String extension = filePath.split('.').last;
    // Lookup MIME type based on file extension
    String? mimeType = lookupMimeType(filePath);
    return mimeType;
  }

  Future<String> getBase64(File file) async {
    String? base64;
    String? contentType = getContentType(file.path);
    if (contentType != null) {
      if (contentType.contains("image")) {
        final uInt8List = file.readAsBytesSync();
        base64 = base64Encode(uInt8List);
      } else {
        final uInt8List = await file.readAsBytes();
        base64 = base64Encode(uInt8List);
      }
      print("contentType: $contentType");
    }
    return base64 ?? "";
  }

  checkTypeFile(File file) {
    var filename = file.path.split(".");
    if (filename[filename.length - 1] == 'pdf') {
      return "assets/svg/pdf.svg";
    } else if (filename[filename.length - 1] == 'png') {
      return "assets/svg/png.svg";
    } else if (filename[filename.length - 1] == 'jpg') {
      return "assets/svg/jpg.svg";
    } else if (filename[filename.length - 1] == 'xls') {
      return "assets/svg/xls.svg";
    } else if (filename[filename.length - 1] == 'jpeg') {
      return "assets/svg/jpg.svg";
    } else {
      return '';
    }
  }

  Future<void> uploadFile() async {
    if (filesList.length >= 5) {
      return debugPrint("Maximum file limit reached");
    }
    result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowCompression: true,
      allowedExtensions: [
        'pdf',
        'xls',
      ],
    );

    if (result != null) {
      var listTemp = result!.paths.map((path) => File(path!)).toList();
      filesList.addAll(
          listTemp.take(5 - filesList.length)); // Take only remaining slots
      update(['home']);
      debugPrint("-----List $filesList");
    } else {
      debugPrint("No file selected");
      update(['home']);
    }
    update(['home']);
  }

  Future<void> uploadPhoto() async {
    if (filesList.length >= 5) {
      return debugPrint("Maximum file limit reached");
    }
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      await Permission.photos.request();
      status = await Permission.photos.status;
      if (!status.isGranted) {
        return debugPrint('Permission denied for accessing photos');
      }
    }
    result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
      allowCompression: true,
    );
    if (result != null && result!.files.isNotEmpty) {
      final List<File> listTemp =
          result!.paths.map((path) => File(path!)).toList();
      filesList.addAll(listTemp.take(5 - filesList.length));
      update(['home']);
      debugPrint("-----Photo List $filesList");
    } else {
      debugPrint("No photo selected");
      update(['home']);
    }
  }
}
