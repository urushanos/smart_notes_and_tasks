import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/app_state.dart';
import '../widgets/progress_heatmap.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final username = app.currentProfile?.username ?? app.currentAuthUser?.email?.split('@').first ?? 'User';
    final profilePhotoPath = app.currentProfile?.photoPath;
   final hasPhoto = profilePhotoPath != null && profilePhotoPath.isNotEmpty;
    final now = DateTime.now();
    final completion = <DateTime, int>{};
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthDays = DateUtils.getDaysInMonth(previousMonthStart.year, previousMonthStart.month);
    final currentMonthDays = DateUtils.getDaysInMonth(currentMonthStart.year, currentMonthStart.month);
    for (var dayNum = 1; dayNum <= previousMonthDays; dayNum++) {
      final day = DateUtils.dateOnly(DateTime(previousMonthStart.year, previousMonthStart.month, dayNum));
      final count = app.tasks.where((t) => t.completedDate != null && DateUtils.isSameDay(t.completedDate, day)).length;
      completion[day] = count == 0 ? 0 : count == 1 ? 1 : count <= 3 ? 2 : 3;
    }
    for (var dayNum = 1; dayNum <= currentMonthDays; dayNum++) {
      final day = DateUtils.dateOnly(DateTime(currentMonthStart.year, currentMonthStart.month, dayNum));
      final count = app.tasks.where((t) => t.completedDate != null && DateUtils.isSameDay(t.completedDate, day)).length;
      completion[day] = count == 0 ? 0 : count == 1 ? 1 : count <= 3 ? 2 : 3;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  foregroundImage: hasPhoto ? NetworkImage(profilePhotoPath!) : null,
                  child: hasPhoto ? const Icon(Icons.person, size: 38) : const Icon(Icons.person, size: 38),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: IconButton.filledTonal(
                    onPressed: _pickProfileImage,
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            app.firstLogin ? 'Welcome $username' : 'Welcome back $username',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  _statCell('Completion Rate', '${_winRate(app)}%'),
                  _divider(),
                  _statCell('Current Streak', '${app.currentStreak} Days'),
                  _divider(),
                  _statCell('Best Streak', '${app.bestStreak} Days'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Daily Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(DateFormat('MMMM yyyy').format(now), style: const TextStyle(fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => app.signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _statCell(String title, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade300,
    );
  }

  int _winRate(AppState app) {
    final total = app.tasks.length;
    if (total == 0) return 0;
    return ((app.completedCount / total) * 100).round();
  }

  Future<void> _pickProfileImage() async {
    final selected = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (selected == null) return;
    if (!mounted) return;
    await context.read<AppState>().updateProfilePhotoPath(selected.path);
  }
}
