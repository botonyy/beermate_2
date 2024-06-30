import 'package:beermate_2/reuseable_widgets/reuseable_widgets.dart';
import 'package:beermate_2/screens/home_screen.dart';
import 'package:beermate_2/screens/regist_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              _inputField(context),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
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

  _inputField(context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const CustomTextField(
          hintText: 'Email',
          prefixIcon: Icons.person,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [],
          obscureText: false),
      const CustomTextField(
          hintText: 'Jelszó',
          prefixIcon: Icons.password,
          keyboardType: TextInputType.text,
          inputFormatters: [],
          obscureText: true),
      const SizedBox(height: 215),
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
                  MaterialPageRoute(builder: (context) => const HomePage()));
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color.fromARGB(255, 209, 208, 208),
            ),
            child: const Text(
              "Bejelentkezés",
              style: TextStyle(fontSize: 16),
            ),
          )),
    ]);
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Még nincs fiókod?"),
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterPage()));
            },
            child: const Text(
              "Regisztráció",
              style: TextStyle(color: Color.fromARGB(255, 105, 104, 104)),
            ))
      ],
    );
  }
}
