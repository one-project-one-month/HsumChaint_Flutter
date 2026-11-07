import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/mobile_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mobile_repository.dart';
import 'common.dart';
import 'donation_form.dart';

class DonationsScreen extends StatefulWidget {
  final MobileRepository repo;
  final UserModel user;
  final List<Monastery> mine;
  final VoidCallback onChanged;
  const DonationsScreen({
    super.key,
    required this.repo,
    required this.user,
    required this.mine,
    required this.onChanged,
  });
  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final _scrollController = ScrollController();
  final List<Donation> _items = [];
  int? _nextCursor;
  bool _hasNextPage = true;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _error;
  int? monasteryId, status;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.user.isMonk && widget.mine.isNotEmpty) {
      monasteryId = widget.mine.first.id;
    }
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoadingInitial = true;
      _error = null;
    });
    try {
      final result = await widget.repo.donationsFeed(
        pageSize: 15,
        monasteryId: monasteryId,
        donorId: widget.user.isDonor ? int.parse(widget.user.id) : null,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _items.clear();
        _items.addAll(result.items);
        _nextCursor = result.nextCursor;
        _hasNextPage = result.hasNextPage;
        _isLoadingInitial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNextPage || _nextCursor == null) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await widget.repo.donationsFeed(
        lastId: _nextCursor,
        pageSize: 15,
        monasteryId: monasteryId,
        donorId: widget.user.isDonor ? int.parse(widget.user.id) : null,
        status: status,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _nextCursor = result.nextCursor;
        _hasNextPage = result.hasNextPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _reload() async {
    await _loadInitial();
    widget.onChanged();
  }

  Future<void> _create() async {
    if (widget.mine.isEmpty) {
      context.go('/monasteries');
      return;
    }
    final changed = await showDonationForm(
      context,
      widget.repo,
      widget.user,
      widget.mine,
    );
    if (changed && mounted) _reload();
  }

  Future<void> _filters() async {
    final result = await showDonationFilters(
      context,
      monasteries: widget.mine,
      monasteryId: monasteryId,
      status: status,
      scopeLabel: 'အားလုံး',
    );
    if (result == null || !mounted) return;
    setState(() {
      monasteryId = result.$1;
      status = result.$2;
    });
    _loadInitial();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeading(
              title: widget.user.isMonk
                  ? 'အလှူစာရင်းများ'
                  : 'မိမိ၏ လှူဒါန်းမှုများ',
              description: 'အလှူမှတ်တမ်းနှင့် လက်ရှိအခြေအနေများ',
              action: widget.user.can('Donation.Create')
                  ? FilledButton.icon(
                      onPressed: _create,
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(
                        widget.user.isMonk
                            ? 'ဆွမ်းစာရင်းသွင်းရန်'
                            : 'လှူဒါန်းရန်',
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _filters,
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(
                    monasteryId != null || status != null
                        ? 'စစ်ထုတ်ထားသည်'
                        : 'စစ်ထုတ်ရန်',
                  ),
                ),
                if (monasteryId != null)
                  for (final m in widget.mine.where((m) => m.id == monasteryId))
                    InputChip(
                      label: Text(m.name),
                      onDeleted: () {
                        setState(() => monasteryId = null);
                        _loadInitial();
                      },
                    ),
                if (status != null)
                  InputChip(
                    label: Text(donationStatuses[status!]),
                    onDeleted: () {
                      setState(() => status = null);
                      _loadInitial();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: _buildBody(context),
      ),
    ],
  );

  Widget _buildBody(BuildContext context) {
    if (_isLoadingInitial) {
      return const ShimmerSkeletonList();
    }

    if (_error != null && _items.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 48, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                'အချက်အလက် ရယူ၍ မရသေးပါ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('ပြန်လည် ကြိုးစားမည်'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: _items.isEmpty
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EmptyStateView(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'လှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ',
                  description:
                      'ဆွမ်း သို့မဟုတ် ဝတ္ထုငွေ လှူဒါန်းမှုများကို ဤနေရာတွင် စာရင်းသွင်း ကြည့်ရှုနိုင်ပါသည်။',
                ),
              ],
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _items.length + 1,
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return BottomLoadingIndicator(isLoading: _isLoadingMore);
                }

                final d = _items[index];
                return DonationCard(
                  key: ValueKey(d.id),
                  donation: d,
                  repo: widget.repo,
                  user: widget.user,
                  mine: widget.mine,
                  onChanged: _reload,
                );
              },
            ),
    );
  }
}

class DonationCard extends StatefulWidget {
  final Donation donation;
  final MobileRepository repo;
  final UserModel user;
  final List<Monastery> mine;
  final VoidCallback onChanged;
  const DonationCard({
    super.key,
    required this.donation,
    required this.repo,
    required this.user,
    required this.mine,
    required this.onChanged,
  });
  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final d = widget.donation;
    final matches = widget.mine.where((m) => m.id == d.monasteryId);
    final monastery = matches.isEmpty ? null : matches.first;
    final operate = monastery?.canOperate == true;
    final actions = <String, String>{
      'detail': 'အသေးစိတ်',
      if (operate && (widget.user.can('Donation.Review') || widget.user.can('Donation.Schedule')) && d.status != 3)
        'status': 'အခြေအနေ ပြောင်းရန်',
      if (operate && widget.user.can('Donation.Review') && d.isActive)
        'review': 'လက်ခံ / ငြင်းပယ်',
      if (operate && widget.user.can('Donation.Schedule') && d.isActive)
        'schedule': 'အချိန်သတ်မှတ်ရန်',
      if (operate && widget.user.can('Donation.Schedule') && d.isActive)
        'complete': 'ကပ်လှူပြီးစီး',
      if ((operate || d.donorId?.toString() == widget.user.id) &&
          widget.user.can('Donation.Cancel') &&
          d.isActive)
        'cancel': 'ပယ်ဖျက်ရန်',
      if (operate && widget.user.can('Donation.Delete') && d.status != 3)
        'delete': 'ဖျက်ရန်',
    };
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusLabel = d.statusLabel;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    d.type == 1
                        ? Icons.rice_bowl_outlined
                        : Icons.volunteer_activism_outlined,
                    color: scheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.type == 5 && d.customType.isNotEmpty
                            ? d.customType
                            : d.typeLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('အလှူမှတ်တမ်း #${d.id}', style: muted),
                    ],
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: PopupMenuButton<String>(
                      tooltip: 'လုပ်ဆောင်ချက်များ',
                      onSelected: _action,
                      icon: Icon(
                        Icons.more_horiz,
                        color: scheme.onSurfaceVariant,
                      ),
                      itemBuilder: (_) => actions.entries
                          .map(
                            (e) => PopupMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (d.amount != null) ...[
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: NumberFormat.decimalPattern().format(d.amount),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    TextSpan(
                      text: ' ကျပ်',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 17,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    d.donorName.isEmpty ? 'အလှူရှင်' : d.donorName,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.temple_buddhist_outlined,
                  size: 17,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    monastery?.name ?? 'ကျောင်းတိုက် အမှတ်စဉ် ${d.monasteryId}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (d.quantity != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'အရေအတွက်: ${NumberFormat.decimalPattern().format(d.quantity)}',
                  style: muted,
                ),
              ),
            const SizedBox(height: 18),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: d.status, label: statusLabel),
            ),
            const SizedBox(height: 12),
            if (d.pickup == null && d.dropoff == null)
              _scheduleLine(Icons.schedule_outlined, 'အချိန် မသတ်မှတ်ရသေးပါ')
            else ...[
              _scheduleLine(Icons.north_east, 'ကြိုယူ: ${dateLabel(d.pickup)}'),
              const SizedBox(height: 6),
              _scheduleLine(
                Icons.south_west,
                'ပြန်ပို့: ${dateLabel(d.dropoff)}',
              ),
            ],
            if (d.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  d.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleLine(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(
          icon,
          size: 15,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );

  Future<void> _action(String action) async {
    final d = widget.donation;
    Json? body;
    if (action == 'detail') {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('အလှူမှတ်တမ်း အမှတ် ${d.id}'),
          content: SizedBox(
            width: 400,
            height: 340,
            child: LoadView(
              future: widget.repo.object('/api/v1/donations/${d.id}'),
              retry: () {
                Navigator.pop(context);
                _action('detail');
              },
              builder: (json) {
                final detail = Donation.fromJson(json);
                return SingleChildScrollView(
                  child: Text(
                    [
                      detail.typeLabel,
                      detail.statusLabel,
                      detail.donorName,
                      detail.customType,
                      detail.note,
                      'ကြိုယူ: ${dateLabel(detail.pickup)}',
                      'ပြန်ပို့: ${dateLabel(detail.dropoff)}',
                      'ပြီးစီး: ${dateLabel(detail.completed)}',
                    ].where((s) => s.isNotEmpty).join('\n\n'),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ပိတ်ရန်'),
            ),
          ],
        ),
      );
      return;
    }
    if (action == 'status') {
      body = await showDialog<Json>(
        context: context,
        builder: (_) => _UpdateStatusDialog(currentStatus: d.status),
      );
      if (body == null || !mounted) return;
    } else if (action == 'review') {
      body = await showDialog<Json>(
        context: context,
        builder: (_) => const _ReviewDialog(),
      );
      if (body == null || !mounted) return;
    } else if (action == 'schedule') {
      final pickup = await pickDateTime(context, initial: d.pickup);
      if (pickup == null || !mounted) return;
      final dropoff = await pickDateTime(context, initial: d.dropoff ?? pickup);
      if (dropoff == null || !mounted) return;
      if (dropoff.isBefore(pickup)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ပြန်ပို့ချိန်သည် ကြိုယူချိန်နောက် ဖြစ်ရပါမည်။'),
          ),
        );
        return;
      }
      body = {
        'pickupTime': pickup.toUtc().toIso8601String(),
        'dropoffTime': dropoff.toUtc().toIso8601String(),
      };
    } else {
      if (!await confirmAction(
            context,
            action == 'delete'
                ? 'ဤလှူဒါန်းမှုကို ဖျက်ရန်'
                : action == 'cancel'
                ? 'ဤလှူဒါန်းမှုကို ပယ်ဖျက်ရန်'
                : 'ကပ်လှူပြီးစီးကြောင်း အတည်ပြုရန်',
          ) ||
          !mounted) {
        return;
      }
    }
    setState(() => busy = true);
    final ok = await runAction(
      context,
      () => widget.repo.donationAction(d.id, action, body: body),
    );
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) widget.onChanged();
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();
  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final note = TextEditingController();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('အလှူမှတ်တမ်း စစ်ဆေးရန်'),
    content: TextField(
      controller: note,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'ဆုတောင်းမေတ္တာ / မှတ်ချက်'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('မလုပ်တော့ပါ'),
      ),
      TextButton(
        onPressed: () =>
            Navigator.pop(context, {'status': 4, 'note': note.text.trim()}),
        child: const Text('ငြင်းပယ်ရန်'),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(context, {'status': 1, 'note': note.text.trim()}),
        child: const Text('လက်ခံရန်'),
      ),
    ],
  );
}

class _UpdateStatusDialog extends StatefulWidget {
  final int currentStatus;
  const _UpdateStatusDialog({required this.currentStatus});

  @override
  State<_UpdateStatusDialog> createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<_UpdateStatusDialog> {
  late int selectedStatus;
  final note = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('အလှူမှတ်တမ်း အခြေအနေ ပြောင်းရန်'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'အခြေအနေ အသစ်'),
            value: selectedStatus,
            items: [
              for (var i = 0; i < donationStatuses.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(donationStatuses[i], overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => selectedStatus = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: note,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'မှတ်ချက် (စိတ်ကြိုက်)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('မလုပ်တော့ပါ'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, {
          'status': selectedStatus,
          'note': note.text.trim(),
        }),
        child: const Text('ပြောင်းလဲမည်'),
      ),
    ],
  );
}
