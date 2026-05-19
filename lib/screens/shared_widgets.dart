import 'package:flutter/material.dart';
import 'app_theme.dart';

// ─── Status Badge ────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  const StatusBadge(this.label, {super.key});

  Color get _color {
    switch (label) {
      case 'Active':
        return AppColors.green;
      case 'Upcoming':
        return AppColors.amber;
      case 'Closed':
        return AppColors.textSecondary;
      case 'Council':
        return AppColors.amber;
      case 'Passed':
        return AppColors.green;
      case 'Failed':
        return AppColors.red;
      default:
        return AppColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Vote Progress Bar ───────────────────────────────────────────
class VoteProgressBar extends StatelessWidget {
  final int forPct, againstPct, abstainPct;
  final double height;
  const VoteProgressBar({
    super.key,
    required this.forPct,
    required this.againstPct,
    required this.abstainPct,
    this.height = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: forPct,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(height),
                    bottomLeft: Radius.circular(height),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: againstPct,
              child: Container(height: height, color: AppColors.red),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: abstainPct,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: const Color(0xFF444466),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(height),
                    bottomRight: Radius.circular(height),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'For $forPct%',
              style: const TextStyle(color: AppColors.green, fontSize: 11),
            ),
            const SizedBox(width: 10),
            Text(
              'Against $againstPct%',
              style: const TextStyle(color: AppColors.red, fontSize: 11),
            ),
            const SizedBox(width: 10),
            Text(
              'Abstain $abstainPct%',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── App Card ────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: child,
      ),
    );
  }
}

// ─── Primary Button ──────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool enabled;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? (color ?? AppColors.purple)
              : AppColors.border,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

// ─── Outline Button ──────────────────────────────────────────────
class OutlineButton2 extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const OutlineButton2({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? AppColors.textSecondary,
          side: BorderSide(color: color ?? AppColors.border),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Avatar ──────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  const UserAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(color: AppColors.purple, fontSize: 13),
            ),
          ),
      ],
    );
  }
}

// ─── Custom Toggle ───────────────────────────────────────────────
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.purple : AppColors.border,
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
