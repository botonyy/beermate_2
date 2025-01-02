import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  /// Kamera engedély kérése
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Külső tárhely engedély kérése Android 11 és újabb verziókhoz
  Future<bool> requestManageStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    } else {
      var status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
  }

  /// Több engedély egyszerre kérése
  Future<bool> requestMultiplePermissions() async {
    var statuses = await [
      Permission.camera,
      Permission.manageExternalStorage, // Scoped Storage engedély
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }
}
