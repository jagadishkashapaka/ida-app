import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/session.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/schedule_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/providers/admin_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  Session? _previousLiveSession;

  @override
  void initState() {
    super.initState();
    // Refresh every minute to check for schedule updates
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _checkForSessionChange();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkForSessionChange() {
    final currentLive = ref.read(currentSessionProvider);

    // If there's a new live session, show notification
    if (currentLive != null && currentLive != _previousLiveSession) {
      _showSessionNotification(currentLive);
      _previousLiveSession = currentLive;
    }
  }

  void _showSessionNotification(Session session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Now Live: ${session.title}'),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to schedule if needed
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get dynamic schedule data
    final liveSession = ref.watch(currentSessionProvider);
    final upNextList = ref.watch(upNextSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('media/logo.jpeg'),
        ),
        title: const Text('IDA Conference'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              if (ref.read(isAdminProvider)) {
                context.push('/admin-schedule');
              } else {
                _showAdminLoginDialog(context);
              }
            },
            icon: Icon(
              ref.watch(isAdminProvider) ? Icons.admin_panel_settings : Icons.lock_outline,
              color: ref.watch(isAdminProvider) ? Colors.green : null,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Live Now'),
            const SizedBox(height: 12),
            liveSession != null
                ? _buildLiveNowCard(context, liveSession)
                : _buildNoLiveSession(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Up Next'),
            const SizedBox(height: 12),
            if (upNextList.isEmpty)
              _buildNoUpcomingSessions(context)
            else
              ...upNextList.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSessionCard(context, session),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Image.asset('media/brander.jpeg', fit: BoxFit.contain);
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNoLiveSession(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            const Text('No live sessions at the moment'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoUpcomingSessions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            const Text('All sessions completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveNowCard(BuildContext context, Session session) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(session.time),
                const Spacer(),
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(session.hall),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  child: Icon(Icons.person, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.speakerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Session session) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.event_note),
        ),
        title: Text(
          session.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${session.speakerName} • ${session.hall}'),
        trailing: Text(
          session.time,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  void _showAdminLoginDialog(BuildContext context) {
    final userController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
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
              final success = AdminAuthService.login(
                userController.text,
                passController.text,
              );
              if (success) {
                ref.read(isAdminProvider.notifier).login();
                Navigator.pop(context);
                context.push('/admin-schedule');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid credentials')),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
