import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  Future<bool> isStoragePermission() async {
    var isStorage = await Permission.storage.status;
    var isAcces = await Permission.accessMediaLocation.status;
    var isMnag = await Permission.manageExternalStorage.status;

    if(!isStorage.isGranted || !isAcces.isGranted || isMnag.isGranted) {
      await Permission.storage.request();
      await Permission.accessMediaLocation.request();
      await Permission.manageExternalStorage.request();
      if (!isStorage.isGranted || !isAcces.isGranted || isMnag.isGranted) {
        return false;
      } else {
        return true;
      }
    }
    else {
      return true;
    }
  }
}


