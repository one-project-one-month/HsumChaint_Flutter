import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/mobile_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mobile_repository.dart';
import 'common.dart';

/// The API adds a TimeSpan to UTC midnight of the selected calendar day.
/// A signed offset preserves the user's local day, including times before UTC midnight.
String recurringTimeSpan(TimeOfDay time, DateTime date) {
  final local = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  final minutes = time.hour * 60 + time.minute - local.timeZoneOffset.inMinutes;
  final absolute = minutes.abs();
  return '${minutes < 0 ? '-' : ''}${(absolute ~/ 60).toString().padLeft(2, '0')}:${(absolute % 60).toString().padLeft(2, '0')}:00';
}

Future<bool> showDonationForm(
  BuildContext context,
  MobileRepository repo,
  UserModel user,
  List<Monastery> mine, {
  Monastery? selected,
}) async =>
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DonationForm(
          repo: repo,
          user: user,
          mine: mine,
          selected: selected,
        ),
      ),
    ) ??
    false;

class DonationForm extends StatefulWidget {
  final MobileRepository repo;
  final UserModel user;
  final List<Monastery> mine;
  final Monastery? selected;
  const DonationForm({
    super.key,
    required this.repo,
    required this.user,
    required this.mine,
    this.selected,
  });
  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(),
      quantity = TextEditingController(),
      note = TextEditingController();
  final donorName = TextEditingController(),
      donorId = TextEditingController(),
      customType = TextEditingController();
  final day = TextEditingController(text: '${DateTime.now().day}'),
      months = TextEditingController(text: '3');
  final batch = <Json>[];
  int? monasteryId;
  int type = 1;
  bool manual = false, recurring = false, busy = false;
  DateTime start = DateTime.now();
  DateTime? pickup, dropoff;
  TimeOfDay? pickupTime, dropoffTime;
  List<Monastery> get options {
    final map = {for (final m in widget.mine) m.id: m};
    if (widget.selected != null) map[widget.selected!.id] = widget.selected!;
    return map.values.toList();
  }

  bool get canManual =>
      options.any((m) => m.id == monasteryId && m.canOperate) &&
      widget.user.can('Donation.Review');
  @override
  void initState() {
    super.initState();
    monasteryId =
        widget.selected?.id ??
        (widget.mine.isEmpty ? null : widget.mine.first.id);
    manual = widget.user.isMonk && canManual;
  }

  @override
  void dispose() {
    for (final c in [
      amount,
      quantity,
      note,
      donorName,
      donorId,
      customType,
      day,
      months,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? numeric(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = num.tryParse(value);
    return number == null || !number.isFinite || number < 0
        ? 'သုညနှင့်အထက် ကိန်းဂဏန်း ဖြည့်ပါ။'
        : null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('လှူဒါန်းမှု အသစ်')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: form,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: monasteryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'ကျောင်းတိုက်',
                    ),
                    items: [
                      for (final m in options)
                        DropdownMenuItem(value: m.id, child: Text(m.name)),
                    ],
                    validator: (v) =>
                        v == null ? 'ကျောင်းတိုက် ရွေးပေးပါ။' : null,
                    onChanged: busy || batch.isNotEmpty
                        ? null
                        : (v) => setState(() {
                            monasteryId = v;
                            if (!canManual) manual = false;
                          }),
                  ),
                  if (options.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'ကျောင်းတိုက်များ စာမျက်နှာမှ ကျောင်းတိုက်ရွေးပြီး လှူဒါန်းနိုင်ပါသည်။',
                      ),
                    ),
                  if (canManual)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('တိုက်ရိုက် အလှူစာရင်းသွင်းမည်'),
                      subtitle: const Text('အလှူရှင်ကိုယ်စား မှတ်တမ်းတင်ရန်'),
                      value: manual,
                      onChanged: busy || batch.isNotEmpty
                          ? null
                          : (v) => setState(() => manual = v),
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('လစဉ် ပုံမှန်လှူဒါန်းမည်'),
                    value: recurring,
                    onChanged: busy || batch.isNotEmpty
                        ? null
                        : (v) => setState(() => recurring = v),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'လှူဖွယ်အမျိုးအစား',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (var i = 0; i < donationTypes.length; i++)
                        ChoiceChip(
                          label: Text(donationTypes[i]),
                          selected: type == i,
                          onSelected: busy
                              ? null
                              : (_) => setState(() => type = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (type == 5)
                    _field(
                      'လှူဖွယ်အမည်',
                      customType,
                      validator: (v) =>
                          v?.trim().isEmpty != false ? 'ဖြည့်ပေးပါ။' : null,
                    ),
                  if (manual) ...[
                    _field(
                      'အလှူရှင်အမည်',
                      donorName,
                      validator: (v) =>
                          donorId.text.trim().isEmpty &&
                              v?.trim().isEmpty != false
                          ? 'အလှူရှင် အမည် သို့မဟုတ် အကောင့်နံပါတ် ဖြည့်ပါ။'
                          : null,
                    ),
                    _field(
                      'အလှူရှင် အကောင့်နံပါတ် (ရှိပါက)',
                      donorId,
                      number: true,
                      validator: (v) =>
                          v == null || v.isEmpty || (int.tryParse(v) ?? 0) > 0
                          ? null
                          : 'မှန်ကန်သော အကောင့်နံပါတ် ဖြည့်ပါ။',
                    ),
                  ],
                  _field(
                    'အလှူငွေ (ကျပ်)',
                    amount,
                    number: true,
                    validator: numeric,
                  ),
                  _field(
                    'အရေအတွက်',
                    quantity,
                    number: true,
                    validator: numeric,
                  ),
                  _field('မှတ်ချက်', note),
                  if (recurring) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('စတင်မည့်လ'),
                      subtitle: Text(DateFormat('MMM yyyy').format(start)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: busy
                          ? null
                          : () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: start,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100, 12, 31),
                              );
                              if (date != null && mounted) {
                                setState(() => start = date);
                              }
                            },
                    ),
                    _field(
                      'လစဉ် ရက် (၁–၃၁)',
                      day,
                      number: true,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n < 1 || n > 31
                            ? '၁ မှ ၃၁ အတွင်း ဖြည့်ပါ။'
                            : null;
                      },
                    ),
                    _field(
                      'လအရေအတွက် (၁–၂၄)',
                      months,
                      number: true,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n < 1 || n > 24
                            ? '၁ မှ ၂၄ အတွင်း ဖြည့်ပါ။'
                            : null;
                      },
                    ),
                    const Text(
                      'ရွေးထားသည့်ရက် မရှိသောလတွင် လ၏နောက်ဆုံးရက်ကို သုံးပါမည်။',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    _timeTile('ကြိုယူချိန်', pickupTime, (t) => pickupTime = t),
                    _timeTile(
                      'ပြန်ပို့ချိန်',
                      dropoffTime,
                      (t) => dropoffTime = t,
                    ),
                  ] else ...[
                    _dateTile(
                      'ကြိုယူမည့် နေ့နှင့်အချိန်',
                      pickup,
                      (d) => pickup = d,
                    ),
                    _dateTile(
                      'ပြန်ပို့မည့် နေ့နှင့်အချိန်',
                      dropoff,
                      (d) => dropoff = d,
                    ),
                  ],
                  if (manual && !recurring) ...[
                    OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () {
                              if (!form.currentState!.validate() ||
                                  !_validTimes()) {
                                return;
                              }
                              setState(() {
                                batch.add(_body());
                                donorName.clear();
                                donorId.clear();
                                amount.clear();
                                quantity.clear();
                                note.clear();
                              });
                            },
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('အစုလိုက်စာရင်းထဲ ထည့်ရန်'),
                    ),
                    for (var i = 0; i < batch.length; i++)
                      ListTile(
                        title: Text(
                          '${i + 1}. ${batch[i]['donorName'] ?? batch[i]['donorId']}',
                        ),
                        trailing: IconButton(
                          tooltip: 'စာရင်းမှ ဖယ်ရန်',
                          onPressed: busy
                              ? null
                              : () => setState(() => batch.removeAt(i)),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: busy ? null : _save,
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            batch.isNotEmpty
                                ? 'အစုလိုက် ${batch.length} ခု တင်သွင်းရန်'
                                : 'တင်သွင်းရန်',
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget _field(
    String label,
    TextEditingController controller, {
    bool number = false,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      enabled: !busy,
      validator: validator,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    ),
  );
  Widget _dateTile(
    String label,
    DateTime? value,
    void Function(DateTime?) update,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(dateLabel(value)),
    trailing: value == null
        ? const Icon(Icons.schedule)
        : IconButton(
            tooltip: 'ရှင်းရန်',
            onPressed: busy ? null : () => setState(() => update(null)),
            icon: const Icon(Icons.clear),
          ),
    onTap: busy
        ? null
        : () async {
            final next = await pickDateTime(context, initial: value);
            if (next != null && mounted) setState(() => update(next));
          },
  );
  Widget _timeTile(
    String label,
    TimeOfDay? value,
    void Function(TimeOfDay?) update,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value?.format(context) ?? 'မသတ်မှတ်ရသေးပါ'),
    trailing: value == null
        ? const Icon(Icons.schedule)
        : IconButton(
            tooltip: 'ရှင်းရန်',
            onPressed: busy ? null : () => setState(() => update(null)),
            icon: const Icon(Icons.clear),
          ),
    onTap: busy
        ? null
        : () async {
            final next = await showTimePicker(
              context: context,
              initialTime: value ?? const TimeOfDay(hour: 6, minute: 0),
            );
            if (next != null && mounted) setState(() => update(next));
          },
  );
  bool _validTimes() {
    final invalid = recurring
        ? pickupTime != null &&
              dropoffTime != null &&
              (dropoffTime!.hour * 60 + dropoffTime!.minute) <
                  (pickupTime!.hour * 60 + pickupTime!.minute)
        : pickup != null && dropoff != null && dropoff!.isBefore(pickup!);
    if (invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ပြန်ပို့ချိန်သည် ကြိုယူချိန်နောက် ဖြစ်ရပါမည်။'),
        ),
      );
    }
    return !invalid;
  }

  Json _body() => {
    'monasterySpaceId': monasteryId,
    'donationType': type,
    if (type == 5) 'customDonationType': customType.text.trim(),
    'note': note.text.trim(),
    'amount': num.tryParse(amount.text),
    'quantity': num.tryParse(quantity.text),
    if (manual) ...{
      'donorId': int.tryParse(donorId.text),
      'donorName': donorName.text.trim(),
    },
    if (recurring) ...{
      'startDate': DateTime.utc(
        start.year,
        start.month,
        start.day,
      ).toIso8601String(),
      'dayOfMonth': int.parse(day.text),
      'monthsCount': int.parse(months.text),
      'pickupTimeOfDay': pickupTime == null
          ? null
          : recurringTimeSpan(pickupTime!, start),
      'dropoffTimeOfDay': dropoffTime == null
          ? null
          : recurringTimeSpan(dropoffTime!, start),
    } else ...{
      'pickupTime': pickup?.toUtc().toIso8601String(),
      'dropoffTime': dropoff?.toUtc().toIso8601String(),
    },
  };
  Future<void> _save() async {
    if (batch.isNotEmpty &&
        [
          donorName,
          donorId,
          amount,
          quantity,
          note,
        ].any((c) => c.text.trim().isNotEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ဖြည့်စွက်ထားသော အလှူကို စာရင်းထဲသို့ အရင်ထည့်သွင်းပေးပါ။'),
        ),
      );
      return;
    }
    if (batch.isEmpty && (!form.currentState!.validate() || !_validTimes())) {
      return;
    }
    setState(() => busy = true);
    final ok = await runAction(context, () async {
      if (batch.isNotEmpty) {
        await widget.repo.call(
          'POST',
          '/api/v1/donations/batch',
          body: {'monasterySpaceId': monasteryId, 'donations': batch},
        );
      } else {
        await widget.repo.donate(_body(), manual: manual, recurring: recurring);
      }
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) Navigator.pop(context, true);
  }
}
