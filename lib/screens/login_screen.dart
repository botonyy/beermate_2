import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/home_screen.dart';
import 'package:beermate_2/screens/regist_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CustomTextField(
        controller: emailController,
        hintText: 'Email',
        prefixIcon: Icons.person,
        keyboardType: TextInputType.emailAddress,
        obscureText: false,
        inputFormatters: [],
      ),
      const SizedBox(height: 16),
      CustomTextField(
        controller: passwordController,
        hintText: 'Jelszó',
        prefixIcon: Icons.password,
        keyboardType: TextInputType.text,
        obscureText: true,
        inputFormatters: [],
      ),
    ]);
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
    UserCredential _ = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (context.mounted) {
      if (e.code == 'user-not-found') {
        _showErrorDialog(context, 'Nincs ilyen felhasználó.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog(context, 'Hibás jelszó.');
      } else if (e.code == 'invalid-credential') {
        _showErrorDialog(context, 'Hibás felhasználónév vagy jelszó.');
      } else {
        _showErrorDialog(context, 'Bejelentkezési hiba történt. Próbáld újra.');
      }
    }
  }
}

Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // A felhasználó megszakította a folyamatot
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Sikeres bejelentkezés után a főoldalra navigál
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      _showErrorDialog(context, 'Hiba történt a Google fiókkal történő bejelentkezés során. Próbáld újra.');
    }
  }

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
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
      );
    },
  );
}

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Még nincs fiókod?"),
        TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => RegisterPage()));
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
