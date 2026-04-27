import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tracks which bottom-nav tab is active (0 = Home, 1 = Study, 2 = Test, 3 = Profile).
// StateProvider was removed in Riverpod 3 — use a simple Notifier instead.
class ShellIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final shellIndexProvider =
    NotifierProvider<ShellIndexNotifier, int>(ShellIndexNotifier.new);
