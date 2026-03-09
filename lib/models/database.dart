/// Database models matching the Supabase schema.
/// Mirrors the web app's types/database.ts

class Profile {
  final String id;
  final String? preferredName;
  final int? age;
  final String? dateOfBirth;
  final String createdAt;

  Profile({
    required this.id,
    this.preferredName,
    this.age,
    this.dateOfBirth,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      preferredName: json['preferred_name'] as String?,
      age: json['age'] as int?,
      dateOfBirth: json['date_of_birth'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preferred_name': preferredName,
      'age': age,
      'date_of_birth': dateOfBirth,
      'created_at': createdAt,
    };
  }
}

class Device {
  final String deviceId;
  final String macAddress;
  final String? firmwareVersion;
  final bool? isActive;
  final String createdAt;

  Device({
    required this.deviceId,
    required this.macAddress,
    this.firmwareVersion,
    this.isActive,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'] as String,
      macAddress: json['mac_address'] as String,
      firmwareVersion: json['firmware_version'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String,
    );
  }
}

class UserDevice {
  final int id;
  final String userId;
  final String deviceId;
  final String? role;

  UserDevice({
    required this.id,
    required this.userId,
    required this.deviceId,
    this.role,
  });

  factory UserDevice.fromJson(Map<String, dynamic> json) {
    return UserDevice(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String,
      role: json['role'] as String?,
    );
  }
}

class MedicalRaw {
  final String id;
  final String deviceId;
  final String dosageStartTime;
  final String? dosageEndTime;
  final String? statusLog;
  final String? createdAt;
  final Map<String, dynamic>? payload;

  MedicalRaw({
    required this.id,
    required this.deviceId,
    required this.dosageStartTime,
    this.dosageEndTime,
    this.statusLog,
    this.createdAt,
    this.payload,
  });

  factory MedicalRaw.fromJson(Map<String, dynamic> json) {
    return MedicalRaw(
      id: json['id'] as String,
      deviceId: json['device_id'] as String,
      dosageStartTime: json['dosage_start_time'] as String,
      dosageEndTime: json['dosage_end_time'] as String?,
      statusLog: json['status_log'] as String?,
      createdAt: json['created_at'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }
}

// Dashboard display types
class DosageHistoryItem {
  final String id;
  final String dosageStartTime;
  final String? dosageEndTime;
  final String? statusLog;
  final String deviceMac;
  final int? durationSeconds;

  DosageHistoryItem({
    required this.id,
    required this.dosageStartTime,
    this.dosageEndTime,
    this.statusLog,
    required this.deviceMac,
    this.durationSeconds,
  });
}

class DosageChartData {
  final String date;
  final int count;
  final int successful;
  final int failed;

  DosageChartData({
    required this.date,
    required this.count,
    required this.successful,
    required this.failed,
  });
}

class DeviceStatusCard {
  final String deviceId;
  final String macAddress;
  final String? firmwareVersion;
  final bool isActive;
  final String? lastDosage;
  final int totalDosages;

  DeviceStatusCard({
    required this.deviceId,
    required this.macAddress,
    this.firmwareVersion,
    required this.isActive,
    this.lastDosage,
    required this.totalDosages,
  });
}

class DashboardData {
  final List<Map<String, dynamic>> recentDosages;
  final int todayCount;
  final int weekCount;
  final int activeDevices;
  final int totalDevices;

  DashboardData({
    required this.recentDosages,
    required this.todayCount,
    required this.weekCount,
    required this.activeDevices,
    required this.totalDevices,
  });
}
