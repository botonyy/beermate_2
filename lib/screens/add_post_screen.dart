import 'dart:io';
import 'package:beermate_2/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:beermate_2/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

class AddNewPostScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  const AddNewPostScreen({super.key, required this.firestoreService});

  @override
  _AddNewPostScreenState createState() => _AddNewPostScreenState();
}

class _AddNewPostScreenState extends State<AddNewPostScreen> {
  final TextEditingController _postContentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _isLoading = false;

  Future<void> _openSystemCamera() async {
    try {
      // A gyári kamera megnyitása és kép készítése
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024, // Beállított max szélesség
        maxHeight: 768, // Beállított max magasság (4:3 képarány)
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("A kép készítése megszakadt.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hiba történt a kép készítésekor: $e")),
      );
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
      // Ellenőrizzük, hogy van-e bejelentkezett felhasználó
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hiba: Nincs bejelentkezett felhasználó!")),
        );
        return;
      }

      // Ellenőrizzük, hogy a Firestore-ban szerepel-e a felhasználói adat
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hiba: A felhasználói adat nem található!")),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_imagePath != null) {
        // Feltöltés Firebase Storage-be
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child("posts/$userId/${DateTime.now().toIso8601String()}.jpg");

        if (!File(_imagePath!).existsSync()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("A fájl nem található!")),
          );
          return;
        }

        await imageRef.putFile(File(_imagePath!));
        imageUrl = await imageRef.getDownloadURL();
      }

      // Poszt hozzáadása Firestore-hoz
      await widget.firestoreService.addPost(
        userId,
        _postContentController.text,
        imageUrl == null ? "text" : "image",
        true,
        imageUrl,
      );

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Új poszt hozzáadása"),
      ),
      body: Column(
        children: [
          if (_imagePath != null)
            Expanded(
              child: Image.file(
                File(_imagePath!),
                fit: BoxFit.contain, // Teljes kép megjelenítése
              ),
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
                        onPressed: _openSystemCamera,
                        child: const Text("Kép hozzáadása"),
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
      ),
    );
  }
}
