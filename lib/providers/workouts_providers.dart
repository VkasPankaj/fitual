import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';

final workoutsProvider = Provider<List<Workout>>((ref) {
  return [
    Workout(
      id: 'full_body',
      title: 'Full Body Workout',
      exercises: ['Push Ups', 'Squats', 'Plank'],
    ),
    Workout(
      id: 'cardio_blast',
      title: 'Cardio Blast',
      exercises: ['Jumping Jacks', 'High Knees', 'Burpees'],
    ),
    Workout(
      id: 'core_crusher',
      title: 'Core Crusher',
      exercises: ['Crunches', 'Russian Twists', 'Leg Raises'],
    ),
  ];
});