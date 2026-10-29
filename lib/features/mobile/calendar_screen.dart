import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/mobile_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mobile_repository.dart';
import 'common.dart';
import 'donations_screen.dart';
import 'donation_form.dart';

class CalendarScreen extends StatefulWidget {
  final MobileRepository repo;
  final UserModel user;
  final List<Monastery> mine;
  final VoidCallback onChanged;
  const CalendarScreen({
    super.key,
    required this.repo,
    required this.user,
    required this.mine,
    required this.onChanged,
  });
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  int? monasteryId, status, selectedDay;
  late Future<CalendarSummary> _future;
  @override
  void initState() {
    super.initState();
    if (widget.user.isMonk && widget.mine.isNotEmpty) {
      monasteryId = widget.mine.first.id;
    }
    _fetch();
  }

  void _fetch() {
    _future = widget.repo.calendar(
      month,
      monasteryId: monasteryId,
      status: status,
    );
  }

  void _reload() {
    setState(_fetch);
    widget.onChanged();
  }

  void _shift(int delta) {
    final next = DateTime(month.year, month.month + delta);
    if (next.year < 2000 || next.year > 2100) return;
    setState(() {
      month = next;
      selectedDay = null;
      _fetch();
    });
  }

  Future<void> _filters() async {
    final result = await showDonationFilters(
      context,
      monasteries: widget.mine,
      monasteryId: monasteryId,
      status: status,
    );
    if (result == null || !mounted) return;
    setState(() {
      monasteryId = result.$1;
      status = result.$2;
      selectedDay = null;
      _fetch();
    });
  }

  void _today() {
    final now = DateTime.now();
    setState(() {
      final changedMonth = month.year != now.year || month.month != now.month;
      month = DateTime(now.year, now.month);
      selectedDay = now.day;
      if (changedMonth) _fetch();
    });
  }

  Future<void> _donate() async {
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

  @override
  Widget build(BuildContext context) => LoadView(
    future: _future,
    retry: _reload,
    builder: (summary) => LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        final donations = summary.days
            .where((day) => selectedDay == null || day['day'] == selectedDay)
            .expand(
              (day) => (day['donations'] as List? ?? []).map(
                (e) => Donation.fromJson(Json.from(e)),
              ),
            )
            .toList();
        final scheme = Theme.of(context).colorScheme;
        final title = widget.user.isMonk
            ? 'ဆွမ်းအလှူအချိန်ဇယား'
            : 'ဆွမ်းပြက္ခဒိန်';
        final calendar = _calendar(summary);
        final agenda = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDay == null
                        ? 'လှူဒါန်းမှုစာရင်း'
                        : DateFormat('d MMMM').format(
                            DateTime(month.year, month.month, selectedDay!),
                          ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (selectedDay != null)
                  TextButton(
                    onPressed: () => setState(() => selectedDay = null),
                    child: const Text('ရက်အားလုံး'),
                  ),
              ],
            ),
            Text(
              '${donations.length} ခု',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (donations.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 32,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ဤကာလအတွင်း လှူဒါန်းမှု မရှိသေးပါ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'အခြားရက်ကို ရွေးချယ်၍ ကြည့်ရှုနိုင်ပါသည်။',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            for (final donation in donations)
              DonationCard(
                key: ValueKey(donation.id),
                donation: donation,
                repo: widget.repo,
                user: widget.user,
                mine: widget.mine,
                onChanged: _reload,
              ),
          ],
        );
        return RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _future;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(wide ? 32 : 20),
            children: [
              PageHeading(
                title: title,
                description: 'နေ့ရက်အလိုက် ဆွမ်းအလှူများကို ကြည့်ရှုစီမံပါ။',
                action: widget.user.can('Donation.Create')
                    ? FilledButton.icon(
                        onPressed: _donate,
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          widget.user.isMonk
                              ? 'ဆွမ်းစာရင်းသွင်းရန်'
                              : 'လှူဒါန်းရန်',
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: scheme.outlineVariant),
                    bottom: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                child: Wrap(
                  spacing: 40,
                  runSpacing: 16,
                  children: [
                    _metric('ယခုလ လှူဒါန်းမှု', '${summary.count} ခု'),
                    _metric(
                      'စုစုပေါင်း အလှူငွေ',
                      '${NumberFormat.decimalPattern().format(summary.amount)} ကျပ်',
                    ),
                    if (widget.user.isMonk)
                      _metric(
                        'လက်ခံရန် စောင့်ဆိုင်းဆဲ',
                        '${summary.days.expand((d) => d['donations'] as List? ?? []).where((d) => d['status'] == 2).length} ခု',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _filters,
                    icon: const Icon(Icons.tune, size: 18),
                    label: Text(
                      status != null || monasteryId != null
                          ? 'စစ်ထုတ်ထားသည်'
                          : 'စစ်ထုတ်ရန်',
                    ),
                  ),
                  if (monasteryId != null)
                    for (final m in widget.mine.where(
                      (m) => m.id == monasteryId,
                    ))
                      InputChip(
                        label: Text(m.name),
                        onDeleted: () => setState(() {
                          monasteryId = null;
                          selectedDay = null;
                          _fetch();
                        }),
                      ),
                  if (status != null)
                    InputChip(
                      label: Text(donationStatuses[status!]),
                      onDeleted: () => setState(() {
                        status = null;
                        _fetch();
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: calendar),
                    const SizedBox(width: 28),
                    Expanded(flex: 5, child: agenda),
                  ],
                )
              else ...[
                calendar,
                const SizedBox(height: 24),
                agenda,
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    ),
  );

  Widget _metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      ),
    ],
  );

  Widget _calendar(CalendarSummary summary) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = month.weekday % 7;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: month,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100, 12, 31),
                    );
                    if (picked != null && mounted) {
                      setState(() {
                        month = DateTime(picked.year, picked.month);
                        selectedDay = picked.day;
                        _fetch();
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    foregroundColor: scheme.onSurface,
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'ယခင်လ',
                onPressed: month.year == 2000 && month.month == 1
                    ? null
                    : () => _shift(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'နောက်လ',
                onPressed: month.year == 2100 && month.month == 12
                    ? null
                    : () => _shift(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth / 7;
              final cellHeight =
                  MediaQuery.textScalerOf(context).scale(16) + 36;
              return Column(
                children: [
                  Row(
                    children: [
                      for (final label in [
                        'Sun',
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                      ])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Wrap(
                    children: [
                      for (var i = 0; i < ((offset + days + 6) ~/ 7) * 7; i++)
                        SizedBox(
                          width: width,
                          height: cellHeight,
                          child: i < offset || i >= offset + days
                              ? null
                              : _day(i - offset + 1, summary),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
          const Divider(height: 24),
          Row(
            children: [
              TextButton.icon(
                onPressed: _today,
                icon: const Icon(Icons.today_outlined, size: 18),
                label: const Text('ယနေ့'),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'ရက်စွဲကို နှိပ်၍ ကြည့်ရန်',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _day(int day, CalendarSummary summary) {
    final count = summary.days
        .where((d) => d['day'] == day)
        .fold<int>(
          0,
          (v, d) => v + ((d['donationsCount'] as num?)?.toInt() ?? 0),
        );
    final today = DateTime.now();
    final isToday =
        month.year == today.year &&
        month.month == today.month &&
        day == today.day;
    final selected = selectedDay == day;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${DateFormat.yMMMd().format(DateTime(month.year, month.month, day))} · $count လှူဒါန်းမှု',
      excludeSemantics: true,
      onTap: () => setState(() => selectedDay = selected ? null : day),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: selected ? scheme.primary : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isToday && !selected ? scheme.primary : Colors.transparent,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => selectedDay = selected ? null : day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                    fontWeight: selected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                if (count > 0)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? scheme.onPrimary : scheme.primary,
                    ),
                  )
                else
                  const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
