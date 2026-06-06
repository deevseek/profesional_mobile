import 'package:flutter/material.dart';
import 'package:profesionalservis_mobile/theme/app_colors.dart';

class ProCard extends StatelessWidget {
  const ProCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : AppColors.border),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryNavy.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: card);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle ?? '', style: TextStyle(color: _muted(context), fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
        if (trailingWidget != null) trailingWidget,
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.hint, this.onChanged, this.trailingIcon = Icons.tune_rounded});

  final String hint;
  final ValueChanged<String>? onChanged;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: Icon(trailingIcon),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.title, required this.value, required this.icon, required this.color, this.delta});

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? delta;

  @override
  Widget build(BuildContext context) {
    final deltaLabel = delta;
    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              if (deltaLabel != null && deltaLabel.isNotEmpty) StatusChip(label: deltaLabel, color: AppColors.success),
            ],
          ),
          const Spacer(),
          Text(title, style: TextStyle(color: _muted(context), fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({super.key, required this.values, this.color = AppColors.primaryBlue});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<double>(1, (max, value) => value > max ? value : max);
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.asMap().entries.map((entry) {
          final height = 28 + (entry.value / maxValue) * 105;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, AppColors.cyan]),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('H${entry.key + 1}', style: TextStyle(color: _muted(context), fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class EmptyStatePanel extends StatelessWidget {
  const EmptyStatePanel({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.primaryBlue),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: _muted(context))),
          ],
        ),
      ),
    );
  }
}

Color _muted(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : AppColors.slate;
