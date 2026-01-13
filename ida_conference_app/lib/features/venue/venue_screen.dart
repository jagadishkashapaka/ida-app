import 'package:flutter/material.dart';

class VenueScreen extends StatelessWidget {
  const VenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.blue.shade100,
              child: const Icon(Icons.map, size: 80, color: Colors.blue),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Convention Centre',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('123 Conference Road, Hyderabad, Telangana'),
                  const SizedBox(height: 24),
                  Text(
                    'Key Locations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Help Desk'),
                    subtitle: Text('Ground Floor Lobby'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text('Lunch Area'),
                    subtitle: Text('Hall C, 1st Floor'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.local_parking),
                    title: Text('Parking'),
                    subtitle: Text('Basement Level 1 & 2'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
