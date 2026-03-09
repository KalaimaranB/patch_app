import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_providers.dart';
import '../models/database.dart';

class DosageHistoryScreen extends ConsumerWidget {
  const DosageHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(dosageHistoryProvider);
    final chartAsync = ref.watch(dosageChartDataProvider);
    final dateRange = ref.watch(dosageDateRangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: const Color(0xFF0D9488),
      onRefresh: () async {
        ref.invalidate(dosageHistoryProvider);
        ref.invalidate(dosageChartDataProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosage History',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track and analyze medication administration records',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // Date range picker
            _DateRangeSelector(
              dateRange: dateRange,
              isDark: isDark,
              onSelect: (range) {
                ref.read(dosageDateRangeProvider.notifier).setRange(range);
              },
              onClear: () {
                ref.read(dosageDateRangeProvider.notifier).setRange(null);
              },
            ),
            const SizedBox(height: 20),

            // Chart
            chartAsync.when(
              data: (chartData) {
                if (chartData.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _DosageChartWidget(
                    data: chartData, isDark: isDark);
              },
              loading: () => Container(
                height: 220,
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF0D9488)),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // History list
            historyAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyHistory(isDark: isDark);
                }
                return Column(
                  children: items
                      .map((item) =>
                          _HistoryItem(item: item, isDark: isDark))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(
                      color: Color(0xFF0D9488)),
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 8),
                    Text('Failed to load history',
                        style: TextStyle(
                            color:
                                isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateTimeRange? dateRange;
  final bool isDark;
  final Function(DateTimeRange) onSelect;
  final VoidCallback onClear;

  const _DateRangeSelector({
    required this.dateRange,
    required this.isDark,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: dateRange,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: const Color(0xFF0D9488),
                          ),
                    ),
                    child: child!,
                  );
                },
              );
              if (range != null) onSelect(range);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1F2937)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: const Color(0xFF0D9488),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dateRange != null
                          ? '${DateFormat('MMM d, y').format(dateRange!.start)} - ${DateFormat('MMM d, y').format(dateRange!.end)}'
                          : 'Select date range',
                      style: TextStyle(
                        fontSize: 14,
                        color: dateRange != null
                            ? (isDark
                                ? Colors.white
                                : const Color(0xFF0F172A))
                            : (isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (dateRange != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1F2937)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DosageChartWidget extends StatelessWidget {
  final List<DosageChartData> data;
  final bool isDark;

  const _DosageChartWidget({required this.data, required this.isDark});

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dosage Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              _LegendDot(
                  color: const Color(0xFF10B981), label: 'Success', isDark: isDark),
              const SizedBox(width: 14),
              _LegendDot(
                  color: const Color(0xFFEF4444), label: 'Failed', isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data
                        .map((e) => e.count.toDouble())
                        .reduce((a, b) => a > b ? a : b) *
                    1.3,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = data[group.x.toInt()];
                      return BarTooltipItem(
                        '${item.date}\n${rodIndex == 0 ? 'Success: ${item.successful}' : 'Failed: ${item.failed}'}',
                        TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length) {
                          return const SizedBox.shrink();
                        }
                        final date = data[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('M/d').format(DateTime.parse(date)),
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF94A3B8),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFE2E8F0),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final d = entry.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: d.successful.toDouble(),
                        color: const Color(0xFF10B981),
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: d.failed.toDouble(),
                        color: const Color(0xFFEF4444),
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final DosageHistoryItem item;
  final bool isDark;

  const _HistoryItem({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isSuccess = item.statusLog == 'Success';
    final time = DateTime.parse(item.dosageStartTime).toLocal();
    final formattedTime = DateFormat('MMM d, y • h:mm a').format(time);
    final duration = item.durationSeconds != null
        ? '${(item.durationSeconds! / 60).toStringAsFixed(1)} min'
        : 'N/A';

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
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
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
                  formattedTime,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      item.deviceMac,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      ' • $duration',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

class _EmptyHistory extends StatelessWidget {
  final bool isDark;
  const _EmptyHistory({required this.isDark});

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
            child: const Icon(Icons.history_rounded,
                color: Color(0xFF0D9488), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'No dosage records',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No data available for the selected period',
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
