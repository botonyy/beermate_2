import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/home_screen.dart';
import 'package:beermate_2/screens/login_screen.dart';
import 'package:beermate_2/screens/regist_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:beermate_2/services/firestore_service.dart'; // Importáljuk a FirestoreService-t

class StarterPage extends StatefulWidget {
  const StarterPage({super.key});

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage> {
  final FirestoreService firestoreService = FirestoreService(); // FirestoreService példány

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = await userDoc.get();

      if (!userData.exists || userData.data()?['username'] == null) {
        String baseUsername = user.email!.split('@').first;
        String generatedUsername = baseUsername;
        int counter = 1;

        bool isUnique = false;
        while (!isUnique) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: generatedUsername)
              .get();

          if (querySnapshot.docs.isEmpty) {
            await userDoc.set({
              'username': generatedUsername,
              'email': user.email,
              'createdAt': FieldValue.serverTimestamp(),
              'phone': '',
            }, SetOptions(merge: true));
            isUnique = true;
          } else {
            generatedUsername = "$baseUsername$counter";
            counter++;
          }
        }
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(firestoreService: firestoreService),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(context, 'Hiba történt a Google fiókkal történő bejelentkezés során. Próbáld újra.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hiba'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'BeerMate', // Megadjuk a megfelelő címet a StarterPage-hez
        showBackButton: false, // Nincs vissza gomb
        showFriendsButton: false, // Nincs "Friends" gomb
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Bejelentkezés',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Bejelentkezés Google fiókkal',
              onPressed: () => signInWithGoogle(context),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Regisztráció',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
