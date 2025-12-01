import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../services/goal_repository.dart';
import '../services/in_memory_goal_repository.dart';

const String _demoUserId = 'demo-user';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return InMemoryGoalRepository();
});

final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.watchGoals(_demoUserId);
});

final goalDetailProvider =
    FutureProvider.family<Goal?, String>((ref, goalId) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.fetchGoalById(goalId);
});


