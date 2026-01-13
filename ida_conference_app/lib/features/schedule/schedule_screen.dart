import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/schedule_provider.dart';
import '../../shared/session_card.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get schedule data from provider
    final schedule = ref.watch(scheduleProvider);
    final day1Sessions = schedule['day1']!;
    final day2Sessions = schedule['day2']!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Day 1'),
              Tab(text: 'Day 2'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: day1Sessions.length,
              itemBuilder: (context, index) =>
                  SessionCard(session: day1Sessions[index]),
            ),
            ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: day2Sessions.length,
              itemBuilder: (context, index) =>
                  SessionCard(session: day2Sessions[index]),
            ),
          ],
        ),
      ),
    );
  }
}
