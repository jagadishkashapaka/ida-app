import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/speaker.dart';

class SpeakersListScreen extends StatelessWidget {
  const SpeakersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final speakers = [
      const Speaker(
        id: '1',
        name: 'Dr. Vijetha B',
        bio: 'Topic: Bend Without Breaking: Expert Strategies for Curved Canals.',
        imageUrl: 'assets/images/speakers/dr_vijetha.png',
        topic: 'Bend Without Breaking',
      ),
      const Speaker(
        id: '2',
        name: 'Dr. Rangarajan V',
        bio: 'Topic: Bruxism - Current Status and Restorative Implications.',
        imageUrl: 'assets/images/speakers/dr_rangarajan.png',
        topic: 'Bruxism',
      ),
      const Speaker(
        id: '3',
        name: 'Dr. Sorna Nagarajan',
        bio: 'Topic: Smart Decisions in Everyday Dentistry: Prevention to Restoration.',
        imageUrl: 'assets/images/speakers/dr_sorna.png',
        topic: 'Smart Decisions in Everyday Dentistry',
      ),
      const Speaker(
        id: '4',
        name: 'Dr. Nemaly Chaithanyaa',
        bio: 'Topic: Corticobasal Implants Myth or Reality.',
        imageUrl: 'assets/images/speakers/dr_nemaly.png',
        topic: 'Corticobasal Implants',
      ),
      const Speaker(
        id: '5',
        name: 'Dr. Mamatha Kaushik',
        bio: 'Topic: Illegally Legal.',
        imageUrl: 'assets/images/speakers/dr_mamatha.png',
        topic: 'Illegally Legal',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Speakers')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: speakers.length,
        itemBuilder: (context, index) {
          final speaker = speakers[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                context.push('/speakers/detail', extra: speaker);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade200,
                      child: speaker.imageUrl.isNotEmpty
                          ? Image.asset(
                              speaker.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 64,
                                  color: Colors.grey,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                              size: 64,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          speaker.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          speaker.topic,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
