import 'package:beermate_2/screens/login_screen.dart';
import 'package:beermate_2/screens/regist_screen.dart';
import 'package:flutter/material.dart';

class StarterPage extends StatelessWidget {
  const StarterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BeerMate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 280,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 209, 208, 208),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all<TextStyle>(
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.transparent),
                  elevation: WidgetStateProperty.all<double>(0),
                ),
                child: const Text('Bejelentkezés'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: 280,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 209, 208, 208),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () async {},
                  style: ButtonStyle(
                    textStyle: WidgetStateProperty.all<TextStyle>(
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.transparent),
                    elevation: WidgetStateProperty.all<double>(0),
                  ),
                  child: const Text('Bejelentkezés Google fiókkal'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 280,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 209, 208, 208),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all<TextStyle>(
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.transparent),
                  elevation: WidgetStateProperty.all<double>(0),
                ),
                child: const Text('Regisztráció'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}