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
        name: 'Dr. John Doe',
        bio: 'Dr. John Doe is a pioneer in modern dentistry...',
        imageUrl: '',
        topic: 'Future of Dentistry',
      ),
      const Speaker(
        id: '2',
        name: 'Dr. Jane Smith',
        bio: 'Specialist in Implantology with 20 years of experience.',
        imageUrl: '',
        topic: 'Implants Workshop',
      ),
      const Speaker(
        id: '3',
        name: 'Dr. Emily Brown',
        bio: 'Renowned cosmetic dentist.',
        imageUrl: '',
        topic: 'Digital Smile Design',
      ),
      const Speaker(
        id: '4',
        name: 'Dr. Michael Green',
        bio: 'Expert in Endodontics.',
        imageUrl: '',
        topic: 'Root Canal Treatments',
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
                      child: const Icon(
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
