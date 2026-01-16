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
      height: 150,
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
              colors: const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            ),
            _OverviewCardData(
              title: 'Active Services',
              value: '${overview.activeServices}',
              icon: Icons.build_circle_outlined,
              colors: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            ),
            _OverviewCardData(
              title: 'Attendance Today',
              value: '${overview.attendanceToday}',
              icon: Icons.fingerprint_outlined,
              colors: const [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
            ),
            _OverviewCardData(
              title: 'Transactions Today',
              value: '${overview.transactionsToday}',
              icon: Icons.receipt_long_outlined,
              colors: const [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            ),
            _OverviewCardData(
              title: 'Open Cash Session',
              value: '${overview.openCashSessions}',
              icon: Icons.point_of_sale_outlined,
              colors: const [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
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
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 20, color: theme.colorScheme.primary),
          ),
          const Spacer(),
          Text(
            data.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
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
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
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
