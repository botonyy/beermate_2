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
        // Ha nincs username, automatikusan létrehozzuk
        final generatedUsername = user!.email!.split('@').first;

        try {
          await userDoc.set({
            'username': generatedUsername,
            'email': user!.email,
            'createdAt': FieldValue.serverTimestamp(),
            'phone': '', // Üres mezőként indul
          }, SetOptions(merge: true));

          usernameController.text = generatedUsername;
          print("Felhasználónév létrehozva: $generatedUsername");
        } catch (e) {
          print("Hiba a felhasználónév mentésekor: $e");
        }
      } else {
        usernameController.text = userData['username'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        print("Felhasználói adatok betöltve: ${userData.data()}");
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

        print("Felhasználói adatok frissítve: Felhasználónév: ${usernameController.text}, Telefonszám: ${phoneController.text}");

        if (passwordController.text.isNotEmpty) {
          try {
            await user!.updatePassword(passwordController.text);
            print("Jelszó frissítve.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Jelszó frissítve!')),
            );
          } catch (e) {
            print("Hiba a jelszó frissítésekor: $e");
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil frissítve!')),
        );
      } catch (e) {
        print("Hiba a felhasználói adatok frissítésekor: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Felhasználónév'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefonszám'),
              keyboardType: TextInputType.phone,
            ),
            if (!isGoogleUser)
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Új jelszó'),
                obscureText: true,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: const Text('Mentés'),
            ),
          ],
        ),
      ),
    );
  }
}
