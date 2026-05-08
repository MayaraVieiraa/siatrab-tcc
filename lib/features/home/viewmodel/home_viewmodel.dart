import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final bool isLoading;
  final List<Map<String, dynamic>> recentCalculations;
  final String welcomeMessage;

  const HomeState({
    this.isLoading = false,
    this.recentCalculations = const [],
    this.welcomeMessage = 'Bem-vindo ao SIATRAB',
  });

  HomeState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? recentCalculations,
    String? welcomeMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      recentCalculations: recentCalculations ?? this.recentCalculations,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  Future<void> loadRecentCalculations() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final mockCalculations = [
        {'date': '15/04/2026', 'type': 'Rescisão', 'value': 5250.00},
        {'date': '10/03/2026', 'type': 'FGTS', 'value': 2100.00},
        {'date': '05/02/2026', 'type': '13º Salário', 'value': 1800.00},
      ];

      state = state.copyWith(
        isLoading: false,
        recentCalculations: mockCalculations,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
