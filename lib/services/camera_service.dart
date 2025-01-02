import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CameraService {
  late CameraController _cameraController;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception("Nincs elérhető kamera.");
    }
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await _cameraController.initialize();
  }

  CameraController get cameraController => _cameraController;

  Future<String> captureImage() async {
    if (!_cameraController.value.isInitialized) {
      throw Exception("Kamera nincs inicializálva.");
    }

    final image = await _cameraController.takePicture();
    return image.path; // A kép mentési helye
  }

Future<String?> uploadImageToStorage(String filePath, String userId) async {
  try {
    // Ellenőrizzük, hogy a fájl létezik-e
    final file = File(filePath);
    if (!file.existsSync()) {
      print("Error: File does not exist at $filePath");
      return null;
    }

    // Feltöltési referencia
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("posts/$userId/${DateTime.now().toIso8601String()}.jpg");

    // Feltöltés
    print("Uploading file to: ${imageRef.fullPath}");
    await imageRef.putFile(file);

    // URL lekérdezése
    final downloadUrl = await imageRef.getDownloadURL();
    print("Download URL: $downloadUrl");
    return downloadUrl;
  } catch (e) {
    print("Hiba a kép feltöltésekor: $e");
    return null;
  }
}



  void disposeCamera() {
    _cameraController.dispose();
  }
}
