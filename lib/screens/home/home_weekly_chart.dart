part of 'home_screen.dart';

// ─── Weekly Study Progress Chart ──────────────────────────────────────────────
class _WeeklyProgressChart extends StatelessWidget {
  /// counts[0] = Monday … counts[6] = Sunday
  final List<int> counts;

  const _WeeklyProgressChart({required this.counts});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final maxY = (counts.reduce((a, b) => a > b ? a : b) + 1).toDouble().clamp(3.0, double.infinity);
    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), counts[i].toDouble()));
    final today = DateTime.now().weekday - 1; // 0 = Mon

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData (
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color:  AppTheme.border,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value != value.roundToDouble()) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: AppTheme.labelSmall.copyWith(fontSize: 10, color: AppTheme.textMuted),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i > 6) return const SizedBox.shrink();
                        final isToday = i == today;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _days[i],
                            style: AppTheme.labelSmall.copyWith(
                              fontSize: 10,
                              color: isToday ? AppTheme.accent : AppTheme.textMuted,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.accent,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, i) {
                        final isToday = i == today;
                        final hasActivity = spot.y > 0;
                        return FlDotCirclePainter(
                          radius: isToday ? 5 : (hasActivity ? 3.5 : 2.5),
                          color: isToday ? AppTheme.accent : (hasActivity ? AppTheme.accent : AppTheme.border),
                          strokeWidth: isToday ? 2 : 0,
                          strokeColor: AppTheme.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accent.withValues(alpha: 0.18),
                          AppTheme.accent.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppTheme.cardBg,
                    tooltipBorder: const BorderSide(color: AppTheme.border),
                    getTooltipItems: (spots) => spots.map((s) {
                      final day = _days[s.x.toInt()];
                      final count = s.y.toInt();
                      return LineTooltipItem(
                        '$day\n$count ${count == 1 ? 'test' : 'tests'}',
                        GoogleFonts.spaceGrotesk(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
