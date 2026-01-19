import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueScreen extends StatelessWidget {
  const VenueScreen({super.key});

  Future<void> _launchMaps() async {
    const double lat = 17.415773;
    const double lng = 78.432697;
    // Google Maps URL schema
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkWell(
              onTap: _launchMaps,
              child: Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 60, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to Open in Maps',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      bottom: 10,
                      right: 10,
                      child: Icon(Icons.open_in_new, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sevalal Banjara Bhavan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_city, size: 20, color: Colors.grey),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Road No 10, Banjara Hills,\nHyderabad, Telangana 500034',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchMaps,
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
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
