import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard_controller.dart';

class OverviewCards extends StatelessWidget {
  const OverviewCards({
    super.key,
    required this.data,
    required this.onRetry,
  });

  final AsyncValue<DashboardOverviewData> data;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: data.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => const _OverviewSkeletonCard(),
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemCount: 4,
        ),
        error: (error, stackTrace) => _OverviewErrorCard(onRetry: onRetry),
        data: (overview) {
          final cards = [
            _OverviewCardData(
              title: 'Total Customers',
              value: '${overview.totalCustomers}',
              icon: Icons.people_alt_outlined,
              colors: const [Color(0xFFEFF6FF), Color(0xFFDCEBFF)],
            ),
            _OverviewCardData(
              title: 'Active Services',
              value: '${overview.activeServices}',
              icon: Icons.build_circle_outlined,
              colors: const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
            ),
            _OverviewCardData(
              title: 'Attendance Today',
              value: '${overview.attendanceToday}',
              icon: Icons.fingerprint_outlined,
              colors: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
            ),
            _OverviewCardData(
              title: 'Transactions Today',
              value: '${overview.transactionsToday}',
              icon: Icons.receipt_long_outlined,
              colors: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            ),
            _OverviewCardData(
              title: 'Open Cash Session',
              value: '${overview.openCashSessions}',
              icon: Icons.point_of_sale_outlined,
              colors: const [Color(0xFFE6FFFB), Color(0xFFCCFBF1)],
            ),
          ];

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _OverviewCard(data: cards[index]),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: cards.length,
          );
        },
      ),
    );
  }
}

class _OverviewCardData {
  const _OverviewCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.data});

  final _OverviewCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 18),
          Text(
            data.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF475569),
            ),
          ),
          const Spacer(),
          Text(
            'Lihat detail',
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewSkeletonCard extends StatelessWidget {
  const _OverviewSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewErrorCard extends StatelessWidget {
  const _OverviewErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gagal memuat ringkasan dashboard. Coba lagi.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
