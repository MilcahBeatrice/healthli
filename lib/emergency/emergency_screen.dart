import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});
  static final List<Map<String, String>> _emergencyContacts = [
    // Example contacts; in a real app, fetch from local DB or Firestore
    // {'name': 'Mom', 'phone': '+1234567890'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Emergency',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // Call Ambulance Button
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  const ambulanceNumber =
                      '112'; // Change to local emergency number
                  final uri = Uri(scheme: 'tel', path: ambulanceNumber);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch dialer')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Call Ambulance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Add Emergency Contact
            GestureDetector(
              onTap: () {
                _showAddContactDialog(context);
              },
              child: const Text(
                '+ Add an Emergency Contact',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Emergency Contacts List
            Expanded(
              child:
                  _emergencyContacts.isEmpty
                      ? const Center(
                        child: Text('No emergency contacts added.'),
                      )
                      : ListView.builder(
                        itemCount: _emergencyContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _emergencyContacts[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.phone,
                                color: Color(0xFF2E7D32),
                              ),
                              title: Text(contact['name'] ?? ''),
                              subtitle: Text(contact['phone'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Color(0xFF2E7D32),
                                ),
                                onPressed: () async {
                                  final uri = Uri(
                                    scheme: 'tel',
                                    path: contact['phone'],
                                  );
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Could not launch dialer',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isNotEmpty && phone.isNotEmpty) {
                  _emergencyContacts.add({'name': name, 'phone': phone});
                  Navigator.of(context).pop();
                  // Force rebuild to show new contact
                  (context as Element).markNeedsBuild();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
