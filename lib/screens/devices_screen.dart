import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: const Color(0xFF0D9488),
      onRefresh: () async => ref.invalidate(devicesProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Devices',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage and monitor your connected medical devices',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            devicesAsync.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return _EmptyDevices(isDark: isDark);
                }
                return Column(
                  children: devices
                      .map((device) =>
                          _DeviceCard(device: device, isDark: isDark))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child:
                      CircularProgressIndicator(color: Color(0xFF0D9488)),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 8),
                      Text('Failed to load devices',
                          style: TextStyle(
                              color:
                                  isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final dynamic device;
  final bool isDark;

  const _DeviceCard({required this.device, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isActive = device.isActive;
    final lastDosage = device.lastDosage != null
        ? DateFormat('MMM d, y • h:mm a')
            .format(DateTime.parse(device.lastDosage).toLocal())
        : 'No dosages recorded';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
                          )
                        : null,
                    color: isActive ? null : (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.memory_rounded,
                    color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.macAddress,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Firmware: ${device.firmwareVersion ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              color: isDark
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFE2E8F0),
              height: 1,
            ),
            const SizedBox(height: 14),
            // Device stats
            Row(
              children: [
                _DeviceStat(
                  icon: Icons.medication_rounded,
                  label: 'Total Dosages',
                  value: device.totalDosages.toString(),
                  isDark: isDark,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _DeviceStat(
                    icon: Icons.schedule_rounded,
                    label: 'Last Dosage',
                    value: lastDosage,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DeviceStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 16,
            color:
                isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF94A3B8),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyDevices extends StatelessWidget {
  final bool isDark;
  const _EmptyDevices({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.devices_rounded,
                color: Color(0xFF0D9488), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'No devices connected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Register a Patch device to get started',
            style: TextStyle(
              fontSize: 13,
              color:
                  isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
