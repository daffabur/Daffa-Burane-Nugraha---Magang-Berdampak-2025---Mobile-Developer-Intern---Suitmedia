import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suitmediatest/provider/user_provider.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
        centerTitle: true, // <--- TAMBAHKAN BARIS INI
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Text(
                  userProvider.userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Selected User Name', // This will be dynamic
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Center(
                  child: Text(
                    userProvider.selectedUserName.isEmpty
                        ? '' // Or a placeholder like "No user selected"
                        : userProvider.selectedUserName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/third');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Example color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Choose a User',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
