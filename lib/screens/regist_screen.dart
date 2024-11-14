import 'package:beermate_2/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: const CustomAppBar(),
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
              inputFormatters: [],
              controller: emailController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Felhasználónév',
              prefixIcon: Icons.person,
              keyboardType: TextInputType.text,
              obscureText: false,
              inputFormatters: [],
              controller: usernameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Telefonszám',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              obscureText: false,
              inputFormatters: [],
              controller: phoneController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Jelszó',
              prefixIcon: Icons.lock,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              inputFormatters: [],
              controller: passwordController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Jelszó megerősítése',
              prefixIcon: Icons.lock,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              inputFormatters: [],
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
        MaterialPageRoute(builder: (context) => const HomePage()),
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
