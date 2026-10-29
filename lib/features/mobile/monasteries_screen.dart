import 'package:flutter/material.dart';
import '../../data/models/mobile_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mobile_repository.dart';
import 'common.dart';
import 'donation_form.dart';

class MonasteriesScreen extends StatefulWidget {
  final MobileRepository repo;
  final UserModel user;
  final List<Monastery> mine;
  final VoidCallback onChanged;
  const MonasteriesScreen({
    super.key,
    required this.repo,
    required this.user,
    required this.mine,
    required this.onChanged,
  });
  @override
  State<MonasteriesScreen> createState() => _MonasteriesScreenState();
}

class _MonasteriesScreenState extends State<MonasteriesScreen> {
  final search = TextEditingController();
  late int section = widget.user.isMonk ? 1 : 0;
  int page = 1;
  String keyword = '';
  bool busy = false;
  late Future<PageData<Monastery>> future;
  late Future<PageData<Json>> invitations;
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void _fetch() {
    if (section == 2) {
      invitations = widget.repo.list(
        '/api/user/${widget.user.id}/invitations',
        page: page,
      );
    } else {
      future = widget.repo.monasteries(
        mine: section == 1,
        keyword: keyword,
        page: page,
      );
    }
  }

  void _reload() => setState(_fetch);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'ကျောင်းတိုက်များ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.user.isMonk && widget.user.can('Monastery.Create'))
                  FilledButton.icon(
                    onPressed: busy ? null : _create,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('ကျောင်းတိုက်အသစ်ဖန်တီးရန်'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('ကျောင်းတိုက်အားလုံး')),
                ButtonSegment(value: 1, label: Text('မိမိကျောင်းတိုက်')),
                ButtonSegment(value: 2, label: Text('ဖိတ်ကြားချက်')),
              ],
              selected: {section},
              onSelectionChanged: (v) => setState(() {
                section = v.first;
                page = 1;
                _fetch();
              }),
            ),
            if (section == 0) ...[
              const SizedBox(height: 12),
              TextField(
                controller: search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'ကျောင်းတိုက် အမည် သို့မဟုတ် မြို့နယ်ဖြင့် ရှာဖွေရန်...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: search,
                    builder: (context, value, _) {
                      if (value.text.isNotEmpty) {
                        return IconButton(
                          tooltip: 'ရှင်းလင်းရန်',
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            search.clear();
                            _search();
                          },
                        );
                      }
                      return IconButton(
                        tooltip: 'ရှာဖွေရန်',
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _search,
                      );
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      Expanded(
        child: section == 2
            ? LoadView(
                future: invitations,
                retry: _reload,
                builder: (result) => RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await invitations;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (result.items.isEmpty)
                        const EmptyStateView(
                          icon: Icons.mark_email_unread_outlined,
                          title: 'ဖိတ်ကြားချက် မရှိသေးပါ',
                          description: 'ကျောင်းတိုက်များမှ အဖွဲ့ဝင် ဖိတ်ကြားလွှာများ မရှိသေးပါ။',
                        ),
                    for (final invitation in result.items)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invitation['monasterySpaceName'] ??
                                    'ကျောင်းတိုက်',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'တာဝန်အဆင့်: ${invitation['spaceRoleName'] ?? spaceRoles[invitation['spaceRoleId']] ?? ''}',
                              ),
                              Text(
                                'ဖိတ်ကြားသူ: ${invitation['invitedByName'] ?? ''}',
                              ),
                              if (invitation['status'] == 0)
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    FilledButton(
                                      onPressed: busy
                                          ? null
                                          : () => _respond(invitation['id'], 1),
                                      child: const Text('လက်ခံရန်'),
                                    ),
                                    OutlinedButton(
                                      onPressed: busy
                                          ? null
                                          : () => _respond(invitation['id'], 2),
                                      child: const Text('ငြင်းပယ်ရန်'),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  invitation['status'] == 1
                                      ? 'လက်ခံပြီး'
                                      : 'ငြင်းပယ်ပြီး',
                                ),
                            ],
                          ),
                        ),
                      ),
                    _pager(result.hasNext, result.totalPages),
                  ],
                ),
              ),
            )
            : LoadView(
                future: future,
                retry: _reload,
                builder: (result) => RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await future;
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (result.items.isEmpty)
                        EmptyStateView(
                          icon: Icons.temple_buddhist_outlined,
                          title: section == 1 ? 'မိမိကျောင်းတိုက် မရှိသေးပါ' : 'ကျောင်းတိုက် မတွေ့ရှိပါ',
                          description: section == 1
                              ? 'သံဃာတော်များ သို့မဟုတ် ကျောင်းစီမံခန့်ခွဲသူများထံမှ ဖိတ်ခေါ်ချက်ကို စောင့်ဆိုင်းပါ သို့မဟုတ် ကျောင်းတိုက်အသစ် ထည့်သွင်းပါ။'
                              : 'ကျောင်းတိုက်အမည် သို့မဟုတ် မြို့နယ်ဖြင့် အသစ်ရှာဖွေကြည့်ပါ။',
                          actionLabel: (section == 1 && widget.user.isMonk && widget.user.can('Monastery.Create'))
                              ? 'ကျောင်းတိုက်အသစ်'
                              : null,
                          onAction: (section == 1 && widget.user.isMonk && widget.user.can('Monastery.Create'))
                              ? _create
                              : null,
                        ),
                      for (final m in result.items) _card(m),
                      _pager(result.hasNext, result.totalPages),
                    ],
                  ),
                ),
              ),
      ),
    ],
  );
  void _search() => setState(() {
    keyword = search.text.trim();
    page = 1;
    _fetch();
  });
  Widget _card(Monastery m) {
    final joined = widget.mine.where((e) => e.id == m.id);
    final current = joined.isEmpty ? m : joined.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.temple_buddhist_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    m.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(m.address),
            if (m.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(m.description),
              ),
            if (current.isMember)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'အဖွဲ့ဝင် · ${spaceRoles[current.roleId] ?? 'Owner'}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            if (widget.user.can('Donation.Create') || current.isMember) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.user.can('Donation.Create'))
                    FilledButton.tonal(
                      onPressed: () async {
                        final changed = await showDonationForm(
                          context,
                          widget.repo,
                          widget.user,
                          widget.mine,
                          selected: current,
                        );
                        if (changed) widget.onChanged();
                      },
                      child: const Text('လှူဒါန်းရန်'),
                    ),
                  const Spacer(),
                  if (current.isMember)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MonasteryDetails(
                              repo: widget.repo,
                              monastery: current,
                            ),
                          ),
                        );
                        if (mounted) widget.onChanged();
                      },
                      child: const Text('အချက်အလက်နှင့် အဖွဲ့ဝင်များ'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pager(bool hasNext, int total) => Row(
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
      Text('$page / ${total == 0 ? 1 : total}'),
      IconButton(
        tooltip: 'နောက်စာမျက်နှာ',
        onPressed: hasNext
            ? () => setState(() {
                page++;
                _fetch();
              })
            : null,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
  Future<void> _respond(int id, int status) async {
    setState(() => busy = true);
    final ok = await runAction(context, () async {
      await widget.repo.call(
        'POST',
        '/api/v1/monasteries/invitations/$id/respond',
        body: {'status': status},
      );
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) {
      _reload();
      widget.onChanged();
    }
  }

  Future<void> _create() async {
    final values = await editFields(
      context,
      'ကျောင်းတိုက်အသစ်',
      {
        'monasteryName': 'ကျောင်းတိုက်အမည်',
        'address': 'လိပ်စာ',
        'description': 'ဖော်ပြချက်',
      },
      requiredKeys: {'monasteryName'},
    );
    if (values == null || !mounted) return;
    setState(() => busy = true);
    final ok = await runAction(context, () async {
      await widget.repo.call('POST', '/api/v1/monasteries', body: values);
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) widget.onChanged();
  }
}

class MonasteryDetails extends StatefulWidget {
  final MobileRepository repo;
  final Monastery monastery;
  const MonasteryDetails({
    super.key,
    required this.repo,
    required this.monastery,
  });
  @override
  State<MonasteryDetails> createState() => _MonasteryDetailsState();
}

class _MonasteryDetailsState extends State<MonasteryDetails> {
  late Monastery monastery = widget.monastery;
  late Future<PageData<Json>> members;
  int page = 1;
  bool busy = false, changed = false;
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    members = monastery.canManage
        ? widget.repo.list(
            '/api/v1/monasteries/${monastery.id}/members',
            page: page,
          )
        : Future.value(const PageData<Json>([], 1, 0, 0));
  }

  void _reload() => setState(_fetch);
  @override
  Widget build(BuildContext context) => PopScope<bool>(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        title: Text(monastery.name),
        leading: IconButton(
          tooltip: 'နောက်သို့',
          onPressed: busy ? null : () => Navigator.pop(context, changed),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(monastery.address),
                if (monastery.description.isNotEmpty)
                  Text(monastery.description),
                if (monastery.canManage)
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: busy ? null : _edit,
                        child: const Text('ပြင်ဆင်ရန်'),
                      ),
                      FilledButton.tonal(
                        onPressed: busy ? null : _invite,
                        child: const Text('အဖွဲ့ဝင်ဖိတ်ရန်'),
                      ),
                      if (monastery.isOwner)
                        TextButton(
                          onPressed: busy ? null : _delete,
                          child: const Text('ကျောင်းတိုက်ဖျက်ရန်'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          Expanded(
            child: LoadView(
              future: members,
              retry: _reload,
              builder: (result) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'အဖွဲ့ဝင်များ (${result.totalCount})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (result.items.isEmpty)
                    EmptyStateView(
                      icon: Icons.group_outlined,
                      title: monastery.canManage
                          ? 'အဖွဲ့ဝင် မရှိသေးပါ'
                          : 'အဖွဲ့ဝင်စာရင်း ကြည့်ရှုခွင့် မရှိပါ',
                      description: monastery.canManage
                          ? 'ကျောင်းတိုက်အတွက် အဖွဲ့ဝင်သစ်များ ဖိတ်ခေါ်နိုင်ပါသည်။'
                          : 'ကျောင်းတိုက်စီမံခန့်ခွဲခွင့်ရှိမှသာ အဖွဲ့ဝင်စာရင်းကို ကြည့်ရှုနိုင်ပါသည်။',
                    ),
                  for (final member in result.items)
                    Card(
                      child: ListTile(
                        title: Text(member['userName'] ?? ''),
                        subtitle: Text(
                          '${member['phoneNumber'] ?? ''}\n${member['spaceRoleName'] ?? ''}',
                        ),
                        isThreeLine: true,
                        trailing:
                            monastery.canManage &&
                                member['isOwner'] != true &&
                                member['spaceRoleId'] != 1
                            ? PopupMenuButton<String>(
                                enabled: !busy,
                                onSelected: (action) =>
                                    _memberAction(member, action),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'role',
                                    child: Text('တာဝန်အဆင့် ပြောင်းလဲရန်'),
                                  ),
                                  PopupMenuItem(
                                    value: 'remove',
                                    child: Text('အဖွဲ့ဝင်စာရင်းမှ ပယ်ဖျက်မည်'),
                                  ),
                                ],
                              )
                            : null,
                      ),
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
        ],
      ),
    ),
  );
  Future<void> _mutate(Future<void> Function() action) async {
    setState(() => busy = true);
    final ok = await runAction(context, action);
    if (!mounted) return;
    setState(() {
      busy = false;
      if (ok) {
        changed = true;
        _fetch();
      }
    });
  }

  Future<void> _edit() async {
    final body = await editFields(
      context,
      'ကျောင်းတိုက်ပြင်ရန်',
      {
        'monasteryName': 'ကျောင်းတိုက်အမည်',
        'address': 'လိပ်စာ',
        'description': 'ဖော်ပြချက်',
      },
      initial: {
        'monasteryName': monastery.name,
        'address': monastery.address,
        'description': monastery.description,
      },
      requiredKeys: {'monasteryName'},
    );
    if (body == null || !mounted) return;
    await _mutate(() async {
      await widget.repo.call(
        'PATCH',
        '/api/v1/monasteries/${monastery.id}',
        body: body,
      );
      final data = await widget.repo.object(
        '/api/v1/monasteries/${monastery.id}',
      );
      monastery = Monastery.fromJson(data);
    });
  }

  Future<void> _delete() async {
    if (!await confirmAction(context, 'ကျောင်းတိုက်အား အပြီးတိုင် ဖျက်မည်') || !mounted) {
      return;
    }
    setState(() => busy = true);
    final ok = await runAction(context, () async {
      await widget.repo.call('DELETE', '/api/v1/monasteries/${monastery.id}');
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) Navigator.pop(context, true);
  }

  Future<void> _invite() async {
    final body = await showDialog<Json>(
      context: context,
      builder: (_) => const _InviteDialog(),
    );
    if (body == null || !mounted) return;
    await _mutate(() async {
      await widget.repo.call(
        'POST',
        '/api/v1/monasteries/${monastery.id}/invitations',
        body: body,
      );
    });
  }

  Future<void> _memberAction(Json member, String action) async {
    if (action == 'remove') {
      if (!await confirmAction(context, 'အဖွဲ့ဝင်စာရင်းမှ ပယ်ဖျက်မည်') || !mounted) return;
      await _mutate(() async {
        await widget.repo.call(
          'DELETE',
          '/api/v1/monasteries/${monastery.id}/members/${member['userId']}',
        );
      });
    } else {
      final role = await showDialog<int>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('တာဝန်အဆင့် ရွေးချယ်ရန်'),
          children: [
            for (final entry in spaceRoles.entries.where((e) => e.key != 1))
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, entry.key),
                child: Text(entry.value),
              ),
          ],
        ),
      );
      if (role == null || !mounted) return;
      await _mutate(() async {
        await widget.repo.call(
          'PUT',
          '/api/v1/monasteries/${monastery.id}/members/${member['userId']}/role',
          body: {'spaceRoleId': role},
        );
      });
    }
  }
}

Future<Json?> editFields(
  BuildContext context,
  String title,
  Map<String, String> labels, {
  Json initial = const {},
  Set<String> requiredKeys = const {},
}) => showDialog<Json>(
  context: context,
  builder: (_) => _FieldsDialog(
    title: title,
    labels: labels,
    initial: initial,
    requiredKeys: requiredKeys,
  ),
);

class _FieldsDialog extends StatefulWidget {
  final String title;
  final Map<String, String> labels;
  final Json initial;
  final Set<String> requiredKeys;
  const _FieldsDialog({
    required this.title,
    required this.labels,
    required this.initial,
    required this.requiredKeys,
  });
  @override
  State<_FieldsDialog> createState() => _FieldsDialogState();
}

class _FieldsDialogState extends State<_FieldsDialog> {
  final form = GlobalKey<FormState>();
  late final controllers = {
    for (final key in widget.labels.keys)
      key: TextEditingController(text: widget.initial[key]?.toString() ?? ''),
  };
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 400,
      child: Form(
        key: form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final key in widget.labels.keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: controllers[key],
                    decoration: InputDecoration(labelText: widget.labels[key]),
                    validator: (v) =>
                        widget.requiredKeys.contains(key) &&
                            v?.trim().isEmpty != false
                        ? 'ကျေးဇူးပြု၍ ဖြည့်စွက်ပေးပါ။'
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('မလုပ်တော့ပါ'),
      ),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(context, {
              for (final entry in controllers.entries)
                entry.key: entry.value.text.trim(),
            });
          }
        },
        child: const Text('သိမ်းရန်'),
      ),
    ],
  );
}

class _InviteDialog extends StatefulWidget {
  const _InviteDialog();
  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final phone = TextEditingController();
  int role = 4;
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('အဖွဲ့ဝင်ဖိတ်ရန်'),
    content: Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'ဖုန်းနံပါတ်'),
            validator: (v) => v?.trim().isEmpty != false ? 'ကျေးဇူးပြု၍ ဖြည့်စွက်ပေးပါ။' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: role,
            decoration: const InputDecoration(labelText: 'တာဝန်အဆင့်'),
            items: [
              for (final entry in spaceRoles.entries.where((e) => e.key != 1))
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (v) => setState(() => role = v!),
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
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(context, {
              'phoneNumber': phone.text.trim(),
              'spaceRoleId': role,
            });
          }
        },
        child: const Text('ဖိတ်ကြားရန်'),
      ),
    ],
  );
}
