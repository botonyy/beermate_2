import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/home_screen.dart';
import 'package:beermate_2/screens/regist_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(),
            _inputField(emailController, passwordController),
            _loginButton(context, emailController, passwordController),
            _signup(context),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          "Bejelentkezés",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Add meg az adataidat a bejelentkezéshez"),
      ],
    );
  }

  Widget _inputField(
      TextEditingController emailController, TextEditingController passwordController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          hintText: 'Email',
          prefixIcon: Icons.person,
          keyboardType: TextInputType.emailAddress,
          obscureText: false,
          inputFormatters: [],
          controller: emailController, // Pass controller here
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'Jelszó',
          prefixIcon: Icons.password,
          keyboardType: TextInputType.text,
          obscureText: true,
          inputFormatters: [],
          controller: passwordController, // Pass controller here
        ),
      ],
    );
  }

  Widget _loginButton(
      BuildContext context, TextEditingController emailController, TextEditingController passwordController) {
    return CustomButton(
      text: 'Bejelentkezés',
      onPressed: () async {
        await signInWithEmailAndPassword(
            context, emailController.text, passwordController.text);
      },
    );
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // Sikeres bejelentkezés
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Nincs ilyen felhasználó.';
      } else if (e.code == 'wrong-password') {
        message = 'Hibás jelszó.';
      } else {
        message = 'Ismeretlen hiba történt.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Még nincs fiókod?"),
        TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const RegisterPage()));
          },
          child: const Text(
            "Regisztráció",
            style: TextStyle(color: Color.fromARGB(255, 105, 104, 104)),
          ),
        ),
      ],
    );
  }
}
