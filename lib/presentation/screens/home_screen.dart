import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../providers/workouts_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart'; // Add this import

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutsProvider);
    final themeMode = ref.watch(themeModeProvider); // Watch theme mode

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Workouts',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => context.go('/home/history'),
            icon: const Icon(Icons.history, color: Colors.blueAccent, size: 28),
            tooltip: 'View History',
          ),
          IconButton(
            onPressed: () {
              // Toggle theme mode
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
            icon: Icon(
              themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
              color: Colors.blueAccent,
              size: 28,
            ),
            tooltip: themeMode == ThemeMode.light ? 'Switch to Dark Mode' : 'Switch to Light Mode',
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Logout', style: GoogleFonts.poppins()),
                  content: Text('Do you want to log out and clear session data?', style: GoogleFonts.poppins()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel', style: GoogleFonts.poppins()),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Logout', style: GoogleFonts.poppins()),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final box = await Hive.openBox('history');
                await box.clear();
                await ref.read(firebaseAuthProvider).signOut();
                context.go('/auth');
              }
            },
            icon: const Icon(Icons.logout, color: Colors.blueAccent, size: 28),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView.separated(
            padding: EdgeInsets.all(constraints.maxWidth * 0.05),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => SizedBox(height: constraints.maxHeight * 0.02),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    leading: Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                      semanticLabel: 'Workout icon',
                    ),
                    title: Text(
                      workout.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${workout.exercises.length} exercises',
                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey,
                      size: 20,
                      semanticLabel: 'Select workout',
                    ),
                    onTap: () => context.go('/home/detail/${workout.id}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}