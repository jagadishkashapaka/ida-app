import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/session.dart';
import '../../core/providers/schedule_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/providers/updates_provider.dart';

class AdminScheduleScreen extends ConsumerStatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  ConsumerState<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends ConsumerState<AdminScheduleScreen> {
  String _selectedDay = 'day1';

  void _editSession(Session session) {
    final titleController = TextEditingController(text: session.title);
    final speakerController = TextEditingController(text: session.speakerName);
    final timeController = TextEditingController(text: session.time);
    final hallController = TextEditingController(text: session.hall);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Session'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: speakerController,
                decoration: const InputDecoration(labelText: 'Speaker'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time Range (e.g. 09:30 AM - 10:00 AM)'),
              ),
              TextField(
                controller: hallController,
                decoration: const InputDecoration(labelText: 'Hall'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedSession = session.copyWith(
                title: titleController.text,
                speakerName: speakerController.text,
                time: timeController.text,
                hall: hallController.text,
              );
              ref.read(scheduleProvider.notifier).updateSession(updatedSession);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(scheduleProvider);
    final sessions = schedule[_selectedDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Manage Announcements',
            onPressed: () => _showManageAnnouncementsDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.campaign),
            tooltip: 'Send Announcement',
            onPressed: () => _showAnnouncementDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset Schedule to Default',
            onPressed: () => _showResetConfirmation(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Day 1'),
                selected: _selectedDay == 'day1',
                onSelected: (selected) {
                  if (selected) setState(() => _selectedDay = 'day1');
                },
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('Day 2'),
                selected: _selectedDay == 'day2',
                onSelected: (selected) {
                  if (selected) setState(() => _selectedDay = 'day2');
                },
              ),
            ],
          ),
        ),
      ),
      body: ReorderableListView.builder(
        itemCount: sessions.length,
        onReorder: (oldIndex, newIndex) {
          ref.read(scheduleProvider.notifier).reorderSessions(_selectedDay, oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            key: ValueKey(session.id),
            title: Text(session.title),
            subtitle: Text('${session.time} • ${session.hall}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(session),
                ),
                const Icon(Icons.drag_handle),
              ],
            ),
            onTap: () => _editSession(session),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSessionDialog() {
    final titleController = TextEditingController();
    final speakerController = TextEditingController();
    final timeController = TextEditingController();
    final hallController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Session'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: speakerController,
                decoration: const InputDecoration(labelText: 'Speaker'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time Range (e.g. 09:30 AM - 10:00 AM)'),
              ),
              TextField(
                controller: hallController,
                decoration: const InputDecoration(labelText: 'Hall'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newSession = Session(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                speakerName: speakerController.text,
                time: timeController.text,
                hall: hallController.text,
                description: descriptionController.text,
              );
              ref.read(scheduleProvider.notifier).addSession(_selectedDay, newSession);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scheduleProvider.notifier).removeSession(session.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final body = bodyController.text;
              
              ref.read(notificationServiceProvider).showImmediateNotification(
                title: title,
                body: body,
              );
              
              ref.read(announcementsProvider.notifier).addAnnouncement(title, body);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Announcement sent!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showManageAnnouncementsDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final announcements = ref.watch(announcementsProvider);
          return AlertDialog(
            title: const Text('Manage Announcements'),
            content: SizedBox(
              width: double.maxFinite,
              child: announcements.isEmpty
                  ? const Text('No manual announcements yet.')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final ann = announcements[index];
                        return ListTile(
                          title: Text(ann.title),
                          subtitle: Text(ann.body),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref.read(announcementsProvider.notifier).removeAnnouncement(ann.id);
                            },
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Schedule'),
        content: const Text(
          'This will overwrite the current schedule with the default data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(scheduleProvider.notifier).initializeDefaultSchedule();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schedule reset to default!')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

extension on Session {
  Session copyWith({
    String? title,
    String? speakerName,
    String? time,
    String? hall,
    String? description,
  }) {
    return Session(
      id: id,
      title: title ?? this.title,
      speakerName: speakerName ?? this.speakerName,
      time: time ?? this.time,
      hall: hall ?? this.hall,
      description: description ?? this.description,
    );
  }
}
