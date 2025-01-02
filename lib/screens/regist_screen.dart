import 'package:beermate_2/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/services/firestore_service.dart'; // Importáljuk a FirestoreService-t

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final firestoreService = FirestoreService(); // FirestoreService példány létrehozása

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Regisztráció', // Megadjuk a megfelelő címet
        showBackButton: true, // Mutatjuk a vissza gombot
        showFriendsButton: false, // Nem kell "Friends" gomb
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              hintText: 'Email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              inputFormatters: const [],
              controller: emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Felhasználónév',
              prefixIcon: Icons.person,
              keyboardType: TextInputType.text,
              obscureText: false,
              inputFormatters: const [],
              controller: usernameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Telefonszám',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              obscureText: false,
              inputFormatters: const [],
              controller: phoneController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Jelszó',
              prefixIcon: Icons.lock,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              inputFormatters: const [],
              controller: passwordController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Jelszó megerősítése',
              prefixIcon: Icons.lock,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              inputFormatters: const [],
              controller: confirmPasswordController,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Regisztráció',
              onPressed: () {
                _registerUser(
                  context,
                  emailController.text,
                  usernameController.text,
                  phoneController.text,
                  passwordController.text,
                  confirmPasswordController.text,
                  firestoreService, // Átadjuk a FirestoreService-t
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser(
    BuildContext context,
    String email,
    String username,
    String phone,
    String password,
    String confirmPassword,
    FirestoreService firestoreService, // FirestoreService paraméter
  ) async {
    if (password != confirmPassword) {
      _showErrorDialog(context, 'A jelszavak nem egyeznek.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(firestoreService: firestoreService), // Átadjuk a HomeScreen-nek
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, 'Hiba: ${e.message}');
    } catch (e) {
      _showErrorDialog(context, 'Ismeretlen hiba történt. Próbáld újra.');
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
}
