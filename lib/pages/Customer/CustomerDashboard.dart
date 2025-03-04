import 'package:flutter/material.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        backgroundColor: Colors.green, // Change this as needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Your Dashboard!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Here you can view your requests, track your orders, and manage your profile.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Add functionality for navigating to another screen or performing an action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Button clicked!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Change button color if needed
              ),
              child: const Text('View Requests'),
            ),
          ],
        ),
      ),
    );
  }
}
