import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutProgressState {
  final int currentExerciseIndex;
  final int secondsLeft;
  final bool isRunning;
  final int exerciseDuration;

  WorkoutProgressState({
    required this.currentExerciseIndex,
    required this.secondsLeft,
    required this.isRunning,
    this.exerciseDuration = 30,
  });

  WorkoutProgressState copyWith({
    int? currentExerciseIndex,
    int? secondsLeft,
    bool? isRunning,
    int? exerciseDuration,
  }) {
    return WorkoutProgressState(
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isRunning: isRunning ?? this.isRunning,
      exerciseDuration: exerciseDuration ?? this.exerciseDuration,
    );
  }
}

class WorkoutProgressNotifier extends StateNotifier<WorkoutProgressState> {
  WorkoutProgressNotifier({required this.totalExercises, this.exerciseDuration = 30})
      : super(WorkoutProgressState(
          currentExerciseIndex: 0,
          secondsLeft: exerciseDuration,
          isRunning: false,
          exerciseDuration: exerciseDuration,
        ));

  final int totalExercises;
  final int exerciseDuration;
  Timer? _timer;

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsLeft > 0) {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      } else {
        if (state.currentExerciseIndex < totalExercises - 1) {
          state = state.copyWith(
            currentExerciseIndex: state.currentExerciseIndex + 1,
            secondsLeft: exerciseDuration,
          );
        } else {
          complete();
        }
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void complete() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      currentExerciseIndex: 0,
      secondsLeft: exerciseDuration,
    );
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      currentExerciseIndex: 0,
      secondsLeft: exerciseDuration,
      isRunning: false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final workoutProgressProvider = StateNotifierProvider.family<
    WorkoutProgressNotifier, WorkoutProgressState, int>((ref, totalExercises) {
  return WorkoutProgressNotifier(totalExercises: totalExercises);
});