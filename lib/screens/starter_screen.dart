import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/home_screen.dart';
import 'package:beermate_2/screens/login_screen.dart';
import 'package:beermate_2/screens/regist_screen.dart';
import 'package:flutter/material.dart';

class StarterPage extends StatelessWidget {
  const StarterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
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
              onPressed: () {
                final loginPage = LoginPage();
                loginPage.signInWithGoogle(context);
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Regisztárció',
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
