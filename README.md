# Smart Task Manager

Flutter + Firebase task manager with:
- Email/password authentication
- Firestore-backed users, groups, and tasks
- Tasks + Calendar + Profile tabs
- Task repeats, steps, completion, and edit/delete flow
- Group color coding and profile analytics (streaks + heatmap)

## Tech Stack
- Flutter
- Provider state management
- Firebase Authentication
- Cloud Firestore

## Firestore Collections
- `users/{uid}`
- `groups/{groupId}`
- `tasks/{taskId}`

Each task stores both `userId` and `groupId`.

## Setup
1. Install Flutter and Firebase CLI tools.
2. Run:
   - `flutter pub get`
   - `flutterfire configure`
3. Replace `lib/firebase_options.dart` with the generated file.
4. Add Firebase platform files (`google-services.json`, `GoogleService-Info.plist`) as needed.
5. Run the app.

For a fresh seed user, default Firestore data includes:
- Groups: `Dailies`, `Study`
- Tasks: `Running`, `Coursera`, `Leetcode Practice`
- Random completed tasks over the last 14 days for heatmap/streak stats.
