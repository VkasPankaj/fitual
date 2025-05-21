import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, Map<String, List<String>>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<Map<String, List<String>>> {
  HistoryNotifier() : super({}) {
    _load();
  }

  final box = Hive.box('history');

 Future<void> _load() async {
  try {
    final Map<String, List<String>> data = {};
    for (final key in box.keys) {
      data[key.toString()] = List<String>.from(box.get(key));
    }
    state = data;
  } catch (e) {
    state = {};
   
  }
}

  Future<void> addWorkout(String date, String workout) async {
    final currentList = box.get(date, defaultValue: <String>[]);
    final updatedList = List<String>.from(currentList)..add(workout);
    await box.put(date, updatedList);
    _load();
  }
}
