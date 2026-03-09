import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/database.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────────────
  static Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() => client.auth.signOut();

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // ── Profile ───────────────────────────────────────────
  static Future<Profile?> getProfile(String userId) async {
    final data = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  static Future<void> updateProfile({
    required String userId,
    String? preferredName,
    int? age,
    String? dateOfBirth,
  }) async {
    final updates = <String, dynamic>{};
    if (preferredName != null) updates['preferred_name'] = preferredName;
    if (age != null) updates['age'] = age;
    if (dateOfBirth != null) updates['date_of_birth'] = dateOfBirth;
    await client.from('profiles').update(updates).eq('id', userId);
  }

  // ── Devices ───────────────────────────────────────────
  static Future<List<String>> getUserDeviceIds(String userId) async {
    final data = await client
        .from('user_devices')
        .select('device_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['device_id'] as String).toList();
  }

  static Future<List<DeviceStatusCard>> getUserDevicesWithStats(
      String userId) async {
    final userDevices = await client
        .from('user_devices')
        .select('device_id, devices(device_id, mac_address, firmware_version, is_active)')
        .eq('user_id', userId);

    final List<DeviceStatusCard> devices = [];
    for (final ud in userDevices) {
      final device = ud['devices'];
      if (device == null) continue;

      final deviceId = device['device_id'] as String;

      // Get dosage count for this device
      final countResult = await client
          .from('medical_raw')
          .select('id')
          .eq('device_id', deviceId);
      final totalDosages = (countResult as List).length;

      // Get last dosage
      final lastDosageResult = await client
          .from('medical_raw')
          .select('dosage_start_time')
          .eq('device_id', deviceId)
          .order('dosage_start_time', ascending: false)
          .limit(1);

      String? lastDosage;
      if ((lastDosageResult as List).isNotEmpty) {
        lastDosage = lastDosageResult[0]['dosage_start_time'] as String;
      }

      devices.add(DeviceStatusCard(
        deviceId: deviceId,
        macAddress: device['mac_address'] as String,
        firmwareVersion: device['firmware_version'] as String?,
        isActive: device['is_active'] as bool? ?? false,
        lastDosage: lastDosage,
        totalDosages: totalDosages,
      ));
    }
    return devices;
  }

  // ── Dashboard Data ────────────────────────────────────
  static Future<DashboardData> getDashboardData(String userId) async {
    // Get device IDs
    final userDevices = await client
        .from('user_devices')
        .select('device_id, devices(device_id, mac_address, firmware_version, is_active)')
        .eq('user_id', userId);

    final deviceIds = (userDevices as List)
        .map((e) => e['device_id'] as String)
        .toList();

    final activeDevices = (userDevices)
        .where((e) => e['devices']?['is_active'] == true)
        .length;

    if (deviceIds.isEmpty) {
      return DashboardData(
        recentDosages: [],
        todayCount: 0,
        weekCount: 0,
        activeDevices: 0,
        totalDevices: 0,
      );
    }

    // Get recent dosages
    final recentDosages = await client
        .from('medical_raw')
        .select('id, dosage_start_time, status_log')
        .inFilter('device_id', deviceIds)
        .order('dosage_start_time', ascending: false)
        .limit(10);

    // Today's count
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayResult = await client
        .from('medical_raw')
        .select('id')
        .inFilter('device_id', deviceIds)
        .gte('dosage_start_time', todayStart.toIso8601String());

    // Week count
    final weekAgo = today.subtract(const Duration(days: 7));
    final weekResult = await client
        .from('medical_raw')
        .select('id')
        .inFilter('device_id', deviceIds)
        .gte('dosage_start_time', weekAgo.toIso8601String());

    return DashboardData(
      recentDosages: List<Map<String, dynamic>>.from(recentDosages),
      todayCount: (todayResult as List).length,
      weekCount: (weekResult as List).length,
      activeDevices: activeDevices,
      totalDevices: deviceIds.length,
    );
  }

  // ── Dosage History ────────────────────────────────────
  static Future<List<DosageHistoryItem>> getDosageHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final deviceIds = await getUserDeviceIds(userId);
    if (deviceIds.isEmpty) return [];

    // Build a map of device_id -> mac_address
    final devices = await getUserDevicesWithStats(userId);
    final macMap = <String, String>{};
    for (final d in devices) {
      macMap[d.deviceId] = d.macAddress;
    }

    var query = client
        .from('medical_raw')
        .select('id, device_id, dosage_start_time, dosage_end_time, status_log')
        .inFilter('device_id', deviceIds);

    if (startDate != null) {
      query = query.gte('dosage_start_time', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte(
          'dosage_start_time',
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
              .toIso8601String());
    }

    final data = await query.order('dosage_start_time', ascending: false);

    return (data as List).map((row) {
      int? durationSeconds;
      if (row['dosage_end_time'] != null) {
        final start = DateTime.parse(row['dosage_start_time']);
        final end = DateTime.parse(row['dosage_end_time']);
        durationSeconds = end.difference(start).inSeconds;
      }
      return DosageHistoryItem(
        id: row['id'] as String,
        dosageStartTime: row['dosage_start_time'] as String,
        dosageEndTime: row['dosage_end_time'] as String?,
        statusLog: row['status_log'] as String?,
        deviceMac: macMap[row['device_id']] ?? 'Unknown',
        durationSeconds: durationSeconds,
      );
    }).toList();
  }

  static Future<List<DosageChartData>> getDosageChartData({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final history = await getDosageHistory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    // Group by date
    final Map<String, DosageChartData> grouped = {};
    for (final item in history) {
      final date =
          DateTime.parse(item.dosageStartTime).toLocal().toString().split(' ')[0];
      final isSuccess = item.statusLog == 'Success';
      if (grouped.containsKey(date)) {
        final existing = grouped[date]!;
        grouped[date] = DosageChartData(
          date: date,
          count: existing.count + 1,
          successful: existing.successful + (isSuccess ? 1 : 0),
          failed: existing.failed + (isSuccess ? 0 : 1),
        );
      } else {
        grouped[date] = DosageChartData(
          date: date,
          count: 1,
          successful: isSuccess ? 1 : 0,
          failed: isSuccess ? 0 : 1,
        );
      }
    }

    final result = grouped.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  // ── Data Management ───────────────────────────────────
  static Future<void> wipeMedicalData(String userId) async {
    final deviceIds = await getUserDeviceIds(userId);
    if (deviceIds.isEmpty) return;

    await client
        .from('medical_raw')
        .delete()
        .inFilter('device_id', deviceIds);
  }

  static Future<void> deleteAccount(String userId) async {
    // Delete medical data first
    await wipeMedicalData(userId);
    // Delete user_devices
    await client.from('user_devices').delete().eq('user_id', userId);
    // Delete profile
    await client.from('profiles').delete().eq('id', userId);
    // Sign out (the actual user deletion needs to be done server-side
    // or via Supabase dashboard edge function)
    await signOut();
  }
}
