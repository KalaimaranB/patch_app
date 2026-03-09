import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(currentUserProvider);
    final dashboardData = ref.watch(dashboardDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: const Color(0xFF0D9488),
      onRefresh: () async {
        ref.invalidate(dashboardDataProvider);
        ref.read(currentUserProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            userData.when(
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.displayName ?? 'Caregiver'}! 👋',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here's an overview of your patient's medical activity.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              loading: () => _buildGreetingSkeleton(isDark),
              error: (_, __) => const Text('Welcome back!'),
            ),
            const SizedBox(height: 24),

            // Stats
            dashboardData.when(
              data: (data) => Column(
                children: [
                  // Stat cards in 2x2 grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: "Today's Doses",
                          value: data.todayCount.toString(),
                          icon: Icons.today_rounded,
                          color: const Color(0xFF0D9488),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'This Week',
                          value: data.weekCount.toString(),
                          icon: Icons.date_range_rounded,
                          color: const Color(0xFF06B6D4),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Active Devices',
                          value: data.activeDevices.toString(),
                          icon: Icons.sensors_rounded,
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Devices',
                          value: data.totalDevices.toString(),
                          icon: Icons.devices_rounded,
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Dosages
                  _SectionHeader(title: 'Recent Activity', isDark: isDark),
                  const SizedBox(height: 12),
                  if (data.recentDosages.isEmpty)
                    _EmptyState(
                      icon: Icons.medication_rounded,
                      title: 'No dosage records yet',
                      subtitle:
                          'Data will appear here once devices start logging',
                      isDark: isDark,
                    )
                  else
                    ...data.recentDosages.map(
                        (dosage) => _DosageCard(dosage: dosage, isDark: isDark)),
                ],
              ),
              loading: () => _buildStatsSkeleton(isDark),
              error: (e, _) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 8),
                    Text('Failed to load dashboard data',
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 4),
                    Text(e.toString(),
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF), fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSkeleton(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 250,
          height: 28,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 300,
          height: 16,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSkeleton(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SkeletonCard(isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard(isDark: isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _SkeletonCard(isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _SkeletonCard(isDark: isDark)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _DosageCard extends StatelessWidget {
  final Map<String, dynamic> dosage;
  final bool isDark;

  const _DosageCard({required this.dosage, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isSuccess = dosage['status_log'] == 'Success';
    final time = DateTime.tryParse(dosage['dosage_start_time'] ?? '');
    final formattedTime = time != null
        ? DateFormat('MMM d, y • h:mm a').format(time.toLocal())
        : 'Unknown time';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSuccess
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isSuccess
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dose ${isSuccess ? 'Administered' : 'Attempted'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedTime,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSuccess
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isSuccess ? 'Success' : 'Failed',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSuccess
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
            child: Icon(icon, color: const Color(0xFF0D9488), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final bool isDark;
  const _SkeletonCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: const Color(0xFF0D9488).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
