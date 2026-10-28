import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int page = 1;
  int? monasteryId, status;
  late Future<PageData<Donation>> future;
  @override
  void initState() {
    super.initState();
    if (widget.user.isMonk && widget.mine.isNotEmpty) {
      monasteryId = widget.mine.first.id;
    }
    _fetch();
  }

  void _fetch() {
    future = widget.repo.donations(
      page: page,
      monasteryId: monasteryId,
      donorId: widget.user.isDonor ? int.parse(widget.user.id) : null,
      status: status,
    );
  }

  void _reload() {
    setState(_fetch);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.user.isMonk
                        ? 'ဆွမ်းစီမံခန့်ခွဲမှု'
                        : 'မိမိ၏ လှူဒါန်းမှုများ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'ပြန်တင်ရန်',
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: monasteryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'ကျောင်းတိုက်',
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('အားလုံး'),
                      ),
                      for (final m in widget.mine)
                        DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => setState(() {
                      monasteryId = v;
                      page = 1;
                      _fetch();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: status,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'အခြေအနေ'),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('အားလုံး'),
                      ),
                      for (var i = 0; i < donationStatuses.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(donationStatuses[i]),
                        ),
                    ],
                    onChanged: (v) => setState(() {
                      status = v;
                      page = 1;
                      _fetch();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.user.can('Donation.Create'))
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final changed = await showDonationForm(
                      context,
                      widget.repo,
                      widget.user,
                      widget.mine,
                    );
                    if (changed && mounted) _reload();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(
                    widget.user.isMonk ? 'ဆွမ်းစာရင်းသွင်းရန်' : 'လှူဒါန်းရန်',
                  ),
                ),
              ),
          ],
        ),
      ),
      Expanded(
        child: LoadView(
          future: future,
          retry: _reload,
          builder: (result) => RefreshIndicator(
            onRefresh: () async {
              _reload();
              await future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (result.items.isEmpty)
                  EmptyStateView(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'လှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ',
                    description:
                        'ဆွမ်း သို့မဟုတ် ဝတ္ထုငွေ လှူဒါန်းမှုများကို ဤနေရာတွင် စာရင်းသွင်း ကြည့်ရှုနိုင်ပါသည်။',
                    actionLabel: widget.user.can('Donation.Create')
                        ? (widget.user.isMonk ? 'ဆွမ်းစာရင်းသွင်းရန်' : 'လှူဒါန်းရန်')
                        : null,
                    onAction: widget.user.can('Donation.Create')
                        ? () async {
                            final changed = await showDonationForm(
                              context,
                              widget.repo,
                              widget.user,
                              widget.mine,
                            );
                            if (changed && mounted) _reload();
                          }
                        : null,
                  ),
                for (final d in result.items)
                  DonationCard(
                    key: ValueKey(d.id),
                    donation: d,
                    repo: widget.repo,
                    user: widget.user,
                    mine: widget.mine,
                    onChanged: _reload,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'ယခင်စာမျက်နှာ',
                      onPressed: page > 1
                          ? () => setState(() {
                              page--;
                              _fetch();
                            })
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '$page / ${result.totalPages == 0 ? 1 : result.totalPages}',
                    ),
                    IconButton(
                      tooltip: 'နောက်စာမျက်နှာ',
                      onPressed: result.hasNext
                          ? () => setState(() {
                              page++;
                              _fetch();
                            })
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
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
      if (operate && widget.user.can('Donation.Delete') && d.status != 5)
        'delete': 'ဖျက်ရန်',
    };
    final color = switch (d.status) {
      2 => Colors.orange.shade800,
      3 || 5 => Colors.green.shade800,
      4 => Colors.blue.shade800,
      6 || 7 => Colors.red.shade700,
      _ => Colors.grey.shade700,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  d.type == 1
                      ? Icons.rice_bowl_outlined
                      : Icons.volunteer_activism_outlined,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${d.typeLabel} · #${d.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  PopupMenuButton<String>(
                    tooltip: 'လုပ်ဆောင်ချက်များ',
                    onSelected: _action,
                    itemBuilder: (_) => actions.entries
                        .map(
                          (e) =>
                              PopupMenuItem(value: e.key, child: Text(e.value)),
                        )
                        .toList(),
                  ),
              ],
            ),
            Text(
              monastery?.name ?? 'ကျောင်းတိုက် #${d.monasteryId}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(d.donorName.isEmpty ? 'အလှူရှင်' : d.donorName),
            if (d.amount != null)
              Text('${NumberFormat.decimalPattern().format(d.amount)} ကျပ်'),
            if (d.quantity != null) Text('အရေအတွက်: ${d.quantity}'),
            const SizedBox(height: 8),
            Text(
              d.statusLabel,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'ကြိုယူ: ${dateLabel(d.pickup)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'ပြန်ပို့: ${dateLabel(d.dropoff)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (d.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(d.note),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _action(String action) async {
    final d = widget.donation;
    Json? body;
    if (action == 'detail') {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('လှူဒါန်းမှု #${d.id}'),
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
    if (action == 'review') {
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
    title: const Text('လှူဒါန်းမှု စစ်ဆေးရန်'),
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
            Navigator.pop(context, {'status': 6, 'note': note.text.trim()}),
        child: const Text('ငြင်းပယ်ရန်'),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(context, {'status': 3, 'note': note.text.trim()}),
        child: const Text('လက်ခံရန်'),
      ),
    ],
  );
}
