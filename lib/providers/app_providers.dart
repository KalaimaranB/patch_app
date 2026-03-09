import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/database.dart';
import '../services/supabase_service.dart';

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

// Current user provider
final currentUserProvider = NotifierProvider<CurrentUserNotifier, AsyncValue<UserData?>>(
  CurrentUserNotifier.new,
);

class UserData {
  final String id;
  final String email;
  final Profile? profile;

  UserData({required this.id, required this.email, this.profile});

  String get displayName =>
      profile?.preferredName ?? email.split('@').first;
}

class CurrentUserNotifier extends Notifier<AsyncValue<UserData?>> {
  @override
  AsyncValue<UserData?> build() {
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      await _fetchUserData(user);
    } else {
      state = const AsyncValue.data(null);
    }

    // Listen for auth changes
    SupabaseService.authStateChanges.listen((authState) async {
      if (authState.event == AuthChangeEvent.signedIn && authState.session?.user != null) {
        await _fetchUserData(authState.session!.user);
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> _fetchUserData(User user) async {
    try {
      final profile = await SupabaseService.getProfile(user.id);
      state = AsyncValue.data(UserData(
        id: user.id,
        email: user.email ?? '',
        profile: profile,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      await _fetchUserData(user);
    }
  }
}

// Dashboard data provider
final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) throw Exception('Not authenticated');
  return SupabaseService.getDashboardData(user.id);
});

// Devices provider
final devicesProvider = FutureProvider.autoDispose<List<DeviceStatusCard>>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) throw Exception('Not authenticated');
  return SupabaseService.getUserDevicesWithStats(user.id);
});

// Dosage history provider with date range
final dosageDateRangeProvider = NotifierProvider<DosageDateRangeNotifier, DateTimeRange?>(
  DosageDateRangeNotifier.new,
);

class DosageDateRangeNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void setRange(DateTimeRange? range) => state = range;
}

final dosageHistoryProvider = FutureProvider.autoDispose<List<DosageHistoryItem>>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) throw Exception('Not authenticated');
  final dateRange = ref.watch(dosageDateRangeProvider);
  return SupabaseService.getDosageHistory(
    userId: user.id,
    startDate: dateRange?.start,
    endDate: dateRange?.end,
  );
});

final dosageChartDataProvider = FutureProvider.autoDispose<List<DosageChartData>>((ref) async {
  final user = SupabaseService.currentUser;
  if (user == null) throw Exception('Not authenticated');
  final dateRange = ref.watch(dosageDateRangeProvider);
  return SupabaseService.getDosageChartData(
    userId: user.id,
    startDate: dateRange?.start,
    endDate: dateRange?.end,
  );
});
