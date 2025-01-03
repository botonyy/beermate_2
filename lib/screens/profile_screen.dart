import 'package:beermate_2/screens/starter_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final userData = await userDoc.get();

      if (!userData.exists || userData.data()?['username'] == null) {
        final generatedUsername = user!.email!.split('@').first;
        await userDoc.set({
          'username': generatedUsername,
          'email': user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'phone': '',
        }, SetOptions(merge: true));
        usernameController.text = generatedUsername;
      } else {
        usernameController.text = userData.data()?['username'] ?? '';
        phoneController.text = userData.data()?['phone'] ?? '';
      }
    }
  }

  Future<void> _updateUserData() async {
    if (usernameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kérjük, töltsd ki az összes mezőt!')),
      );
      return;
    }

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'username': usernameController.text,
          'phone': phoneController.text,
        }, SetOptions(merge: true));

        if (passwordController.text.isNotEmpty) {
          try {
            await user!.updatePassword(passwordController.text);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jelszó frissítve!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Hiba: ${e.toString()}')),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil frissítve!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StarterPage()),
      ); // Navigálás a bejelentkezési oldalra
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hiba a kijelentkezés során: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Felhasználónév'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Telefonszám'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          if (!isGoogleUser)
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Új jelszó'),
              obscureText: true,
            ),
          if (isGoogleUser)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Google-fiókkal regisztrált felhasználók jelszavát nem lehet módosítani.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateUserData,
            child: const Text('Mentés'),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _signOut,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Piros szín
            ),
            child: const Text('Kijelentkezés'),
          ),
        ],
      ),
    );
  }
}
