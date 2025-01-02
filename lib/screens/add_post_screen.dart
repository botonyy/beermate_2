import 'dart:io';
import 'package:beermate_2/screens/home_screen.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beermate_2/services/camera_service.dart';
import 'package:beermate_2/services/firestore_service.dart';
import 'package:beermate_2/services/permission_handler_service.dart';

class AddNewPostScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  const AddNewPostScreen({super.key, required this.firestoreService});

  @override
  _AddNewPostScreenState createState() => _AddNewPostScreenState();
}

class _AddNewPostScreenState extends State<AddNewPostScreen> {
  final TextEditingController _postContentController = TextEditingController();
  final CameraService _cameraService = CameraService();
  final PermissionHandlerService _permissionHandlerService = PermissionHandlerService();

  bool _isCameraInitialized = false;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Kamera engedély ellenőrzése
      final cameraPermissionGranted = await _permissionHandlerService.requestCameraPermission();
      if (!cameraPermissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kamera engedély szükséges a kamera használatához.")),
        );
        return;
      }

      // Kamera inicializálása
      await _cameraService.initializeCamera();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kamera inicializálási hiba: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePicture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tárhely engedély ellenőrzése
      final storagePermissionGranted = await _permissionHandlerService.requestManageStoragePermission();
      if (!storagePermissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tárhely engedély szükséges a kép mentéséhez.")),
        );
        return;
      }

      // Kép készítése
      final imagePath = await _cameraService.captureImage();
      setState(() {
        _imagePath = imagePath;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hiba történt a kép készítésekor: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addPost() async {
  if (_postContentController.text.isEmpty && _imagePath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tölts ki legalább egy mezőt vagy adj hozzá képet!")),
    );
    return;
  }

  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hiba: Nincs bejelentkezett felhasználó!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;
    if (_imagePath != null) {
      print("User ID: $userId");
      print("Image Path: $_imagePath");
      print("Uploading image...");

      imageUrl = await _cameraService.uploadImageToStorage(_imagePath!, userId);

      print("Image URL: $imageUrl");
      print("Adding post...");
    }

    await widget.firestoreService.addPost(
      userId,
      _postContentController.text,
      imageUrl == null ? "text" : "image",
      true,
      imageUrl,
    );

    print("Post added successfully.");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Poszt sikeresen hozzáadva!")),
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(firestoreService: widget.firestoreService),
      ),
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hiba történt a poszt hozzáadása során: $e")),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  void dispose() {
    _cameraService.disposeCamera();
    _postContentController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: _isCameraInitialized
        ? Column(
            children: [
              if (_imagePath != null)
                Image.file(
                  File(_imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Expanded(
                child: CameraPreview(_cameraService.cameraController),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _postContentController,
                      decoration: const InputDecoration(
                        labelText: "Poszt tartalma",
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator(),
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _takePicture,
                            child: const Text("Kép készítése"),
                          ),
                          ElevatedButton(
                            onPressed: _addPost,
                            child: const Text("Poszt hozzáadása"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator()), // Kamera betöltése
  );
}
}