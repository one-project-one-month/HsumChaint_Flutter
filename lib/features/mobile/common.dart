import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

String dateLabel(DateTime? date) => date == null
    ? 'အချိန် မသတ်မှတ်ရသေးပါ'
    : DateFormat('dd MMM yyyy • HH:mm').format(date.toLocal());

/// Reusable Shimmer Skeleton Card matching the Card theme shape
class ShimmerSkeletonCard extends StatelessWidget {
  const ShimmerSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.of(context).disableAnimations;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : const Color(0xFFE4E4E7);
    final highlightColor = isDark ? Colors.grey.shade700 : const Color(0xFFF4F4F5);

    Widget box({double? width, double height = 14, double radius = 6}) =>
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    Widget card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                box(width: 32, height: 32, radius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      box(width: 140, height: 16),
                      const SizedBox(height: 6),
                      box(width: 90, height: 12),
                    ],
                  ),
                ),
                box(width: 50, height: 22, radius: 11),
              ],
            ),
            const SizedBox(height: 16),
            box(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            box(width: 180, height: 12),
          ],
        ),
      ),
    );

    if (disableMotion) return card;

    return card
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: highlightColor,
        );
  }
}

/// Reusable Skeleton List
class ShimmerSkeletonList extends StatelessWidget {
  final int count;
  const ShimmerSkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'ဒေတာ ဆွဲတင်နေပါသည်',
    container: true,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, index) => const ShimmerSkeletonCard(),
    ),
  );
}

/// Accessible Rich Empty State View
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 34,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF71717A),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF71717A),
                      height: 1.4,
                    ),
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget emptyMessage(
  String text, {
  IconData icon = Icons.inbox_outlined,
  String? description,
}) =>
    EmptyStateView(
      icon: icon,
      title: text,
      description: description,
    );

class LoadView<T> extends StatelessWidget {
  final Future<T> future;
  final VoidCallback retry;
  final Widget Function(T data) builder;
  final Widget Function()? skeleton;

  const LoadView({
    super.key,
    required this.future,
    required this.retry,
    required this.builder,
    this.skeleton,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return skeleton?.call() ?? const ShimmerSkeletonList();
      }
      if (snapshot.hasError) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_outlined,
                      size: 34,
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'အချက်အလက် ရယူ၍ မရပါ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF71717A)),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: retry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('ပြန်လည်ကြိုးစားမည်'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return skeleton?.call() ?? const ShimmerSkeletonList();
      }
      return builder(snapshot.data as T);
    },
  );
}

Future<bool> confirmAction(BuildContext context, String title) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('ဤလုပ်ဆောင်ချက်ကို အတည်ပြုပါသလား။'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('မလုပ်တော့ပါ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('အတည်ပြုမည်'),
          ),
        ],
      ),
    ) ??
    false;

Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('လုပ်ဆောင်ပြီးပါပြီ။')));
    }
    return true;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
    return false;
  }
}

Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
}) async {
  final current = (initial ?? DateTime.now()).toLocal();
  final date = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100, 12, 31),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(current),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
