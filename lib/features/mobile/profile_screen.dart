import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/models/mobile_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/mobile_repository.dart';
import '../authentication/controllers/auth_controller.dart';
import 'common.dart';
import 'monasteries_screen.dart';

String _dash(dynamic value) {
  if (value == null) return '-';
  final str = value.toString().trim();
  return str.isEmpty ? '-' : str;
}

class ProfileScreen extends StatefulWidget {
  final MobileRepository repo;
  final AuthController auth;
  const ProfileScreen({super.key, required this.repo, required this.auth});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Json>> future;
  bool busy = false;
  UserModel get user => widget.auth.currentUser.value!;
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    future = Future.wait([
      widget.repo.object('/api/user/${user.id}'),
      widget.repo.object('/api/user/${user.id}/settings'),
      if (user.isMonk) widget.repo.object('/api/user/${user.id}/monk-profile'),
    ]);
  }

  void _reload() => setState(_fetch);
  @override
  Widget build(BuildContext context) {
    return LoadView(
      future: future,
      retry: _reload,
      builder: (data) => RefreshIndicator(
        onRefresh: () async {
          _reload();
          await future;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    child: Icon(Icons.person_outline, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _dash(data[0]['name']),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.isMonk ? 'သံဃာတော်' : 'အလှူရှင်',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const ThemeModeCard(),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('ပရိုဖိုင်အချက်အလက်'),
                    trailing: IconButton(
                      tooltip: 'ပြင်ဆင်ရန်',
                      onPressed: busy ? null : () => _editProfile(data[0]),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                  ListTile(
                    title: const Text('ဖုန်းနံပါတ်'),
                    subtitle: Text(_dash(data[0]['phoneNumber'])),
                  ),
                  ListTile(
                    title: const Text('အီးမေးလ်'),
                    subtitle: Text(_dash(data[0]['email'])),
                  ),
                  ListTile(
                    title: const Text('ဆက်သွယ်ရန်ဖုန်း'),
                    subtitle: Text(_dash(data[0]['contactPhoneNumber'])),
                  ),
                ],
              ),
            ),
            if (user.isMonk)
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('သံဃာတော်၏ ကျောင်းတိုက်'),
                      trailing: IconButton(
                        tooltip: 'ကျောင်းတိုက်အချက်အလက်ပြင်ရန်',
                        onPressed: busy ? null : () => _editMonk(data[2]),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ),
                    ListTile(
                      title: const Text('ကျောင်းတိုက်အမည်'),
                      subtitle: Text(_dash(data[2]['monasteryName'])),
                    ),
                    ListTile(
                      title: const Text('လိပ်စာ'),
                      subtitle: Text(_dash(data[2]['monasteryAddress'])),
                    ),
                  ],
                ),
              ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('ပို့ဆောင်ချိန်နှင့် အသိပေးချိန်'),
                    trailing: IconButton(
                      tooltip: 'အချိန်ပြင်ရန်',
                      onPressed: busy ? null : () => _editSettings(data[1]),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                  for (final entry in settingLabels.entries)
                    ListTile(
                      title: Text(entry.value),
                      subtitle: Text(
                        dateLabel(DateTime.tryParse(data[1][entry.key] ?? '')),
                      ),
                    ),
                ],
              ),
            ),
            if (busy) const LinearProgressIndicator(),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: busy ? null : widget.auth.logout,
              icon: const Icon(Icons.logout),
              label: const Text('အကောင့်ထွက်ရန်'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(Future<void> Function() action) async {
    setState(() => busy = true);
    final ok = await runAction(context, action);
    if (!mounted) return;
    setState(() {
      busy = false;
      if (ok) _fetch();
    });
  }

  Future<void> _editProfile(Json initial) async {
    final body = await editFields(
      context,
      'ပရိုဖိုင်အချက်အလက်',
      {
        'name': 'အမည်',
        'phoneNumber': 'ဖုန်းနံပါတ်',
        'email': 'အီးမေးလ်',
        'contactPhoneNumber': 'ဆက်သွယ်ရန်ဖုန်း',
      },
      initial: initial,
      requiredKeys: {'name', 'phoneNumber'},
    );
    if (body == null || !mounted) return;
    await _save(() async {
      final updated = {...initial, ...body};
      await widget.repo.call('PUT', '/api/user', body: updated);
      widget.auth.currentUser.value = UserModel.fromJson({
        ...updated,
        'accessToken': user.token,
        'refreshToken': user.refreshToken,
        'permissions': user.permissions,
      });
    });
  }

  Future<void> _editMonk(Json initial) async {
    final body = await editFields(
      context,
      'ကျောင်းတိုက်အချက်အလက်',
      {'monasteryName': 'ကျောင်းတိုက်အမည်', 'monasteryAddress': 'လိပ်စာ'},
      initial: initial,
      requiredKeys: {'monasteryName'},
    );
    if (body == null || !mounted) return;
    await _save(() async {
      await widget.repo.call(
        'PATCH',
        '/api/user/${user.id}/monk-profile',
        body: body,
      );
    });
  }

  Future<void> _editSettings(Json initial) async {
    final body = await showDialog<Json>(
      context: context,
      builder: (_) => _SettingsDialog(initial: initial),
    );
    if (body == null || !mounted) return;
    await _save(() async {
      await widget.repo.call(
        'PUT',
        '/api/user/${user.id}/settings',
        body: body,
      );
    });
  }
}

const settingLabels = {
  'pickupTime': 'ဆွမ်းချိုင့် ကြိုယူမည့်အချိန်',
  'dropoffTime': 'ဆွမ်းချိုင့် ပြန်ပို့မည့်အချိန်',
  'pickupNotificationTime': 'ကြိုယူရန် အသိပေးချိန်',
  'dropoffNotificationTime': 'ပြန်ပို့ရန် အသိပေးချိန်',
};

class _SettingsDialog extends StatefulWidget {
  final Json initial;
  const _SettingsDialog({required this.initial});
  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late final values = {
    for (final key in settingLabels.keys)
      key: DateTime.tryParse(widget.initial[key] ?? ''),
  };
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('ပို့ဆောင်ချိန်နှင့် အသိပေးချိန်'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in settingLabels.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value),
                subtitle: Text(dateLabel(values[entry.key])),
                trailing: IconButton(
                  tooltip: 'ရှင်းရန်',
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => values[entry.key] = null),
                ),
                onTap: () async {
                  final date = await pickDateTime(
                    context,
                    initial: values[entry.key],
                  );
                  if (date != null && mounted) {
                    setState(() => values[entry.key] = date);
                  }
                },
              ),
          ],
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
          final pickup = values['pickupTime'], dropoff = values['dropoffTime'];
          if (pickup != null && dropoff != null && dropoff.isBefore(pickup)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ပြန်ပို့ချိန်ကို ပြန်စစ်ပါ။')),
            );
            return;
          }
          Navigator.pop(context, {
            for (final entry in values.entries)
              entry.key: entry.value?.toUtc().toIso8601String(),
          });
        },
        child: const Text('သိမ်းရန်'),
      ),
    ],
  );
}

class ThemeModeCard extends StatelessWidget {
  const ThemeModeCard({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ThemeController>()
        ? Get.find<ThemeController>()
        : Get.put(ThemeController(), permanent: true);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.contrast_outlined),
              title: Text('အသွင်အပြင်'),
              subtitle: Text('စနစ်အတိုင်း၊ နေ့အလင်း သို့မဟုတ် ညမှောင်'),
            ),
            Obx(
              () => Column(
                children: [
                  for (final (mode, label, icon) in [
                    (
                      ThemeMode.system,
                      'စနစ်အတိုင်း',
                      Icons.settings_brightness_outlined,
                    ),
                    (ThemeMode.light, 'နေ့အလင်း', Icons.light_mode_outlined),
                    (ThemeMode.dark, 'ညမှောင်', Icons.dark_mode_outlined),
                  ])
                    Semantics(
                      selected: controller.themeMode == mode,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(icon),
                        title: Text(label),
                        trailing: controller.themeMode == mode
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () async {
                          try {
                            await controller.setThemeMode(mode);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('အသွင်အပြင် သိမ်း၍ မရသေးပါ။'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
