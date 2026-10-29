import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/mobile_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mobile_repository.dart';
import 'common.dart';
import 'donations_screen.dart';

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

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.user.isMonk
                        ? 'ဆွမ်းအလှူအချိန်ဇယား'
                        : 'ဆွမ်းပြက္ခဒိန်',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: monasteryId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'ကျောင်းတိုက်',
                      prefixIcon: const Icon(
                        Icons.temple_buddhist_outlined,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text(
                          'မိမိ၏ လှူဒါန်းမှုများ',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      for (final m in widget.mine)
                        DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => setState(() {
                      monasteryId = v;
                      selectedDay = null;
                      _fetch();
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: status,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'အခြေအနေ',
                      prefixIcon: const Icon(Icons.tune_outlined, size: 20),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('အားလုံး', overflow: TextOverflow.ellipsis),
                      ),
                      for (var i = 0; i < donationStatuses.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(
                            donationStatuses[i],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() {
                      status = v;
                      _fetch();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'ယခင်လ',
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: month,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100, 12, 31),
                    );
                    if (date != null && mounted) {
                      setState(() {
                        month = DateTime(date.year, date.month);
                        selectedDay = null;
                        _fetch();
                      });
                    }
                  },
                  child: Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'နောက်လ',
                  onPressed: () => _shift(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: LoadView(
          future: _future,
          retry: _reload,
          builder: (summary) {
            final days = DateTime(month.year, month.month + 1, 0).day;
            final offset = month.weekday % 7;
            final donations = summary.days
                .where((d) => selectedDay == null || d['day'] == selectedDay)
                .expand(
                  (d) => (d['donations'] as List).map(
                    (e) => Donation.fromJson(Json.from(e)),
                  ),
                )
                .toList();
            final pending = summary.days
                .expand((d) => d['donations'] as List)
                .where((d) => d['status'] == 2)
                .length;
            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ယခုလ လှူဒါန်းမှု ${summary.count} ခု',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'စုစုပေါင်း ${NumberFormat.decimalPattern().format(summary.amount)} ကျပ်',
                          ),
                          if (widget.user.isMonk)
                            Text('လက်ခံရန် စောင့်ဆိုင်းဆဲ $pending ခု'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (final d in [
                        'Sun',
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                      ])
                        Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth / 7;
                      return Wrap(
                        children: [
                          for (
                            var i = 0;
                            i < ((offset + days + 6) ~/ 7) * 7;
                            i++
                          )
                            SizedBox(
                              width: width,
                              height: 52,
                              child: i < offset || i >= offset + days
                                  ? null
                                  : _day(i - offset + 1, summary),
                            ),
                        ],
                      );
                    },
                  ),
                  if (selectedDay != null)
                    TextButton(
                      onPressed: () => setState(() => selectedDay = null),
                      child: const Text('ရက်အားလုံး ပြန်ပြရန်'),
                    ),
                  const Divider(height: 28),
                  Text(
                    selectedDay == null
                        ? 'လှူဒါန်းမှုစာရင်း'
                        : '$selectedDay ရက်နေ့ လှူဒါန်းမှုများ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (donations.isEmpty)
                    const EmptyStateView(
                      icon: Icons.calendar_today_outlined,
                      title: 'ဤကာလအတွင်း လှူဒါန်းမှု မရှိသေးပါ',
                      description:
                          'ရွေးချယ်ထားသော ရက်စွဲ သို့မဟုတ် ကျောင်းတိုက်ကို ပြန်လည်စစ်ဆေးကြည့်ပါ။',
                    ),
                  for (final donation in donations)
                    DonationCard(
                      donation: donation,
                      repo: widget.repo,
                      user: widget.user,
                      mine: widget.mine,
                      onChanged: _reload,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
  Widget _day(int day, CalendarSummary summary) {
    final count = summary.days
        .where((d) => d['day'] == day)
        .fold<int>(0, (v, d) => v + (d['donationsCount'] as int));
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: selectedDay == day
            ? Theme.of(context).colorScheme.primary
            : count > 0
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Semantics(
          button: true,
          selected: selectedDay == day,
          label:
              '${DateFormat.yMMMd().format(DateTime(month.year, month.month, day))} · $count လှူဒါန်းမှု',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () =>
                setState(() => selectedDay = selectedDay == day ? null : day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: selectedDay == day
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
                if (count > 0)
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      color: selectedDay == day
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
