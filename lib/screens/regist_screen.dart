import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regisztráció'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomTextField(
              hintText: 'Email',
              prefixIcon: Icons.format_list_bulleted_rounded,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              inputFormatters: [],
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'Felhasználónév',
              prefixIcon: Icons.format_list_bulleted_rounded,
              keyboardType: TextInputType.text,
              obscureText: false,
              inputFormatters: [],
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'Telefonszám',
              prefixIcon: Icons.phone_android,
              keyboardType: TextInputType.phone,
              obscureText: false,
              inputFormatters: [],
            ),
            const SizedBox(height: 16),
            const CustomTextField(
                hintText: 'Jelszó',
                prefixIcon: Icons.password,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                inputFormatters: []),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'Jelszó megerősítése',
              prefixIcon: Icons.password,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              inputFormatters: [],
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
                onPressed: () {},
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all<TextStyle>(
                    const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.transparent,
                  ),
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
