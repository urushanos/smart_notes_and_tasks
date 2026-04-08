import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/progress_heatmap.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final username = app.currentProfile?.username ?? 'User';
    final completion = <DateTime, int>{};
    for (var i = 13; i >= 0; i--) {
      final day = DateUtils.dateOnly(DateTime.now().subtract(Duration(days: i)));
      final count = app.tasks.where((t) => t.completedDate != null && DateUtils.isSameDay(t.completedDate, day)).length;
      completion[day] = count == 0 ? 0 : count == 1 ? 1 : count <= 3 ? 2 : 3;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            app.firstLogin ? 'Welcome $username' : 'Welcome back $username',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              title: const Text('Current Streak'),
              trailing: Text('${app.currentStreak}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Best Streak'),
              trailing: Text('${app.bestStreak}'),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Daily Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ProgressHeatmap(completionLevels: completion),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(title: const Text('Completed Tasks'), trailing: Text('${app.completedCount}')),
                ListTile(title: const Text('Pending Tasks'), trailing: Text('${app.pendingCount}')),
                ListTile(title: const Text('Overdue Tasks'), trailing: Text('${app.overdueCount}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
