import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../models/workout.dart';
import '../../providers/workout_progress_provider.dart';
import '../../providers/workouts_providers.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const DetailScreen({super.key, required this.workoutId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> with SingleTickerProviderStateMixin {
  late Workout workout;
  final FlutterTts tts = FlutterTts();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    try {
      // Load workout
      final workouts = ref.read(workoutsProvider);
      workout = workouts.firstWhere(
        (w) => w.id == widget.workoutId,
        orElse: () {
          context.go('/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout not found')),
          );
          return workouts[0]; // Fallback to avoid crash
        },
      );

      // Configure TTS
      tts.setLanguage('en-US');
      tts.setPitch(1.0);
      tts.setSpeechRate(0.5);
      tts.setErrorHandler((msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('TTS Error: $msg'))));

      // Initialize animation
      _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _animation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } catch (e) {
      // Handle initialization errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing screen: $e')),
      );
      context.go('/home');
    }
  }

  Future<void> _logWorkout() async {
    try {
      final box = Hive.box('history');
      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final existing = box.get(todayKey, defaultValue: <String>[]);
      final updated = List<String>.from(existing)..add(workout.title);
      await box.put(todayKey, updated);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log workout: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(workoutProgressProvider(workout.exercises.length));
    final progressNotifier = ref.read(workoutProgressProvider(workout.exercises.length).notifier);

    final isRunning = progress.isRunning;
    final currentExercise = workout.exercises[progress.currentExerciseIndex];
    final secondsLeft = progress.secondsLeft;

    // Voice TTS cues
    ref.listen<WorkoutProgressState>(workoutProgressProvider(workout.exercises.length), (previous, next) {
      if (previous?.currentExerciseIndex != next.currentExerciseIndex && next.isRunning) {
        tts.speak('Exercise ${next.currentExerciseIndex + 1} of ${workout.exercises.length}. Start exercise: ${workout.exercises[next.currentExerciseIndex]}');
      }
      if (!next.isRunning && previous?.isRunning == true && next.currentExerciseIndex >= workout.exercises.length - 1) {
        tts.speak('Workout completed');
        _logWorkout();
      }
      if (previous?.isRunning == true && !next.isRunning && next.currentExerciseIndex < workout.exercises.length - 1) {
        tts.speak('Workout paused');
      }
      if (previous?.isRunning == false && next.isRunning) {
        tts.speak('Workout resumed');
      }
      if (next.isRunning && previous?.secondsLeft != next.secondsLeft) {
        if ([10, 5, 3].contains(next.secondsLeft)) {
          tts.speak('${next.secondsLeft} seconds left');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          workout.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, semanticLabel: 'Back to home'),
          onPressed: () {
            if (isRunning) {
              progressNotifier.pause();
            }
            context.go('/home');
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearProgressIndicator(
                  value: (progress.currentExerciseIndex + 1) / workout.exercises.length,
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey[200],
                  minHeight: 8,
                  semanticsLabel: 'Workout progress: ${progress.currentExerciseIndex + 1} of ${workout.exercises.length} exercises',
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Text(
                  'Current Exercise',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  semanticsLabel: 'Current Exercise',
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                Text(
                  currentExercise,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  semanticsLabel: currentExercise,
                ),
                SizedBox(height: constraints.maxHeight * 0.03),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.3,
                      height: constraints.maxWidth * 0.3,
                      child: CircularProgressIndicator(
                        value: secondsLeft / progress.exerciseDuration,
                        strokeWidth: 8,
                        color: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey[200],
                        semanticsLabel: 'Timer progress',
                      ),
                    ),
                    Text(
                      '$secondsLeft s',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      semanticsLabel: '$secondsLeft seconds remaining',
                    ),
                  ],
                ),
                SizedBox(height: constraints.maxHeight * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTapDown: (_) => _controller.forward(),
                      onTapUp: (_) {
                        _controller.reverse();
                        HapticFeedback.lightImpact();
                        isRunning ? progressNotifier.pause() : progressNotifier.start();
                      },
                      onTapCancel: () => _controller.reverse(),
                      child: ScaleTransition(
                        scale: _animation,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.blue.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: null, // Allow GestureDetector to handle tap
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              isRunning ? 'Pause' : progress.secondsLeft == progress.exerciseDuration ? 'Start' : 'Resume',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              semanticsLabel: isRunning
                                  ? 'Pause workout'
                                  : progress.secondsLeft == progress.exerciseDuration
                                      ? 'Start workout'
                                      : 'Resume workout',
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isRunning) ...[
                      SizedBox(width: constraints.maxWidth * 0.05),
                      GestureDetector(
                        onTapDown: (_) => _controller.forward(),
                        onTapUp: (_) {
                          _controller.reverse();
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Complete Workout?', style: GoogleFonts.poppins()),
                              content: Text(
                                'Are you sure you want to end this workout?',
                                style: GoogleFonts.poppins(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel', style: GoogleFonts.poppins()),
                                ),
                                TextButton(
                                  onPressed: () {
                                    progressNotifier.complete();
                                    _logWorkout();
                                    context.go('/home');
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Complete',
                                    style: GoogleFonts.poppins(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onTapCancel: () => _controller.reverse(),
                        child: ScaleTransition(
                          scale: _animation,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.redAccent, Colors.red.shade700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              onPressed: null, // Allow GestureDetector to handle tap
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Complete',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                semanticsLabel: 'Complete workout',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: constraints.maxHeight * 0.02),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    progressNotifier.reset();
                  },
                  child: Text(
                    'Reset Timer',
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                    semanticsLabel: 'Reset timer',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}