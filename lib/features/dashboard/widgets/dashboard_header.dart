import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    this.onNotificationTap,
    this.onLogout,
    this.onProfileTap,
  });

  final String? userName;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _buildInitials(userName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profesional Servis',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selamat datang,',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName ?? '-',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: onNotificationTap,
                  tooltip: 'Notifications',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'profile') {
                      onProfileTap?.call();
                    }
                    if (value == 'logout') {
                      onLogout?.call();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'profile',
                      child: Text('Profile'),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _buildInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'PS';
    }
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    final first = parts[0].characters.first;
    final last = parts[parts.length - 1].characters.first;
    return '${first}${last}'.toUpperCase();
  }
}
