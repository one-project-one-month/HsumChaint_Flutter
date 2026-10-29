import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../data/models/mobile_models.dart';

String dateLabel(DateTime? date) => date == null
    ? 'အချိန် မသတ်မှတ်ရသေးပါ'
    : DateFormat('dd MMM yyyy • HH:mm').format(date.toLocal());

/// Reusable Shimmer Skeleton Card matching the Card theme shape
class ShimmerSkeletonCard extends StatelessWidget {
  const ShimmerSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.of(context).disableAnimations;
    final scheme = Theme.of(context).colorScheme;
    final baseColor = scheme.primaryContainer;
    final highlightColor = scheme.surface;

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
        .shimmer(duration: 1200.ms, color: highlightColor);
  }
}

/// Reusable Skeleton List
class ShimmerSkeletonList extends StatelessWidget {
  final int count;
  const ShimmerSkeletonList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'အချက်အလက်များ ရယူနေပါသည်...',
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
    final scheme = theme.colorScheme;

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
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(icon, size: 34, color: scheme.onPrimaryContainer),
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
                      color: scheme.onSurfaceVariant,
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
}) => EmptyStateView(icon: icon, title: text, description: description);

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
        final scheme = Theme.of(context).colorScheme;
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
                      color: scheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_outlined,
                      size: 34,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'အချက်အလက် ရယူ၍ မရသေးပါ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: retry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('ပြန်လည် ကြိုးစားမည်'),
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

/// Uses the backend donation status values.
class StatusBadge extends StatelessWidget {
  final int status;
  final String label;
  const StatusBadge({super.key, required this.status, required this.label});
  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (status) {
      2 => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
        const Color(0xFFFDE68A),
      ),
      3 => (
        const Color(0xFFECFDF5),
        const Color(0xFF065F46),
        const Color(0xFFA7F3D0),
      ),
      4 || 5 => (
        const Color(0xFFEFF6FF),
        const Color(0xFF1E40AF),
        const Color(0xFFBFDBFE),
      ),
      6 || 7 => (
        const Color(0xFFFEE2E2),
        const Color(0xFF991B1B),
        const Color(0xFFFECACA),
      ),
      _ => (
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.onPrimaryContainer,
        Theme.of(context).colorScheme.outlineVariant,
      ),
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Native buttons retain keyboard activation and accessibility semantics.
class TactileFeedbackWrapper extends StatefulWidget {
  final Widget child;
  final bool enabled;
  const TactileFeedbackWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });
  @override
  State<TactileFeedbackWrapper> createState() => _TactileFeedbackWrapperState();
}

class _TactileFeedbackWrapperState extends State<TactileFeedbackWrapper> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: widget.enabled
          ? (_) {
              HapticFeedback.lightImpact();
              setState(() => pressed = true);
            }
          : null,
      onPointerUp: (_) => setState(() => pressed = false),
      onPointerCancel: (_) => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed && widget.enabled && !reduceMotion ? .97 : 1,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A consistent page introduction that wraps actions on compact screens.
class PageHeading extends StatelessWidget {
  final String title, description;
  final Widget? action;
  const PageHeading({
    super.key,
    required this.title,
    required this.description,
    this.action,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final copy = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      if (action == null) return copy;
      if (constraints.maxWidth < 560) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [copy, const SizedBox(height: 16), action!],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: copy),
          const SizedBox(width: 20),
          action!,
        ],
      );
    },
  );
}

Future<(int?, int?)?> showDonationFilters(
  BuildContext context, {
  required List<Monastery> monasteries,
  required int? monasteryId,
  required int? status,
  String scopeLabel = 'မိမိ၏ လှူဒါန်းမှုများ',
}) {
  var draftMonastery = monasteryId, draftStatus = status;
  return showModalBottomSheet<(int?, int?)>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, update) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'စစ်ထုတ်ရန်',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'ပိတ်ရန်',
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              key: ValueKey('monastery-$draftMonastery'),
              initialValue: draftMonastery ?? -1,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'ကျောင်းတိုက်'),
              items: [
                DropdownMenuItem(
                  value: -1,
                  child: Text(scopeLabel, overflow: TextOverflow.ellipsis),
                ),
                for (final monastery in monasteries)
                  DropdownMenuItem(
                    value: monastery.id,
                    child: Text(
                      monastery.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) =>
                  update(() => draftMonastery = value == -1 ? null : value),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              key: ValueKey('status-$draftStatus'),
              initialValue: draftStatus ?? -1,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'အခြေအနေ'),
              items: [
                const DropdownMenuItem(value: -1, child: Text('အားလုံး')),
                for (var i = 0; i < donationStatuses.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(
                      donationStatuses[i],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) =>
                  update(() => draftStatus = value == -1 ? null : value),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(sheetContext, (draftMonastery, draftStatus)),
              child: const Text('ရလဒ်များ ပြရန်'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => update(() {
                draftMonastery = null;
                draftStatus = null;
              }),
              child: const Text('စစ်ထုတ်မှုများ ရှင်းရန်'),
            ),
          ],
        ),
      ),
    ),
  );
}
