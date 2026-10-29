import '../../../presentation/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/mobile_models.dart';
import '../../../data/repositories/mobile_repository.dart';
import '../../../data/services/api_service.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../mobile/calendar_screen.dart';
import '../../mobile/donations_screen.dart';
import '../../mobile/monasteries_screen.dart';
import '../../mobile/notifications_screen.dart';
import '../../mobile/profile_screen.dart';
import '../../mobile/common.dart';

class HomeScreen extends StatefulWidget {
  final String tab;
  const HomeScreen({super.key, this.tab = 'calendar'});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = Get.find<AuthController>();
  late final repo = MobileRepository(Get.find<ApiService>());
  late Future<List<Monastery>> _mine;
  int _unread = 0;
  static const tabs = [
    'calendar',
    'donations',
    'monasteries',
    'notifications',
    'profile',
  ];
  @override
  void initState() {
    super.initState();
    _mine = repo.allMine();
    _loadUnread();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) _loadUnread();
  }

  Future<void> _loadUnread() async {
    final user = auth.currentUser.value;
    if (user == null) return;
    try {
      var count = 0;
      var page = 1;
      while (true) {
        final result = await repo.list(
          '/api/user/${user.id}/notification',
          page: page++,
        );
        count += result.items.where((n) => n['isRead'] != true).length;
        if (!result.hasNext) break;
      }
      if (mounted) setState(() => _unread = count);
    } catch (_) {
      /* Notification page exposes its own retry state. */
    }
  }

  void _refresh() {
    setState(() => _mine = repo.allMine());
    _loadUnread();
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser.value;
    if (user == null) return const SizedBox.shrink();
    final index = tabs.indexOf(widget.tab);
    final labels = [
      user.isMonk ? 'ဆွမ်းဇယား' : 'ပြက္ခဒိန်',
      'လှူဒါန်းမှု',
      'ကျောင်းတိုက်',
      'အသိပေးချက်',
      'ပရိုဖိုင်',
    ];
    final icons = [
      Icons.calendar_month_outlined,
      Icons.volunteer_activism_outlined,
      Icons.temple_buddhist_outlined,
      Icons.notifications_outlined,
      Icons.person_outline,
    ];
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final selected = index < 0 ? 0 : index;
    final content = LoadView(
      future: _mine,
      retry: _refresh,
      builder: (mine) => switch (widget.tab) {
        'donations' => DonationsScreen(
          repo: repo,
          user: user,
          mine: mine,
          onChanged: _loadUnread,
        ),
        'monasteries' => MonasteriesScreen(
          repo: repo,
          user: user,
          mine: mine,
          onChanged: _refresh,
        ),
        'notifications' => NotificationsScreen(
          repo: repo,
          userId: int.parse(user.id),
          onChanged: _loadUnread,
        ),
        'profile' => ProfileScreen(repo: repo, auth: auth),
        _ => CalendarScreen(
          repo: repo,
          user: user,
          mine: mine,
          onChanged: _loadUnread,
        ),
      },
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        titleSpacing: 20,
        shape: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        title: const AppHeaderTitle(title: 'ဆွမ်းချိုင့်'),
        actions: [
          if (wide)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(user.name, style: theme.textTheme.bodyMedium),
            ),
          if (widget.tab == 'calendar')
            IconButton(
              tooltip: 'အသိပေးချက်',
              onPressed: () => context.go('/notifications'),
              icon: Badge(
                isLabelVisible: _unread > 0,
                label: Text('$_unread'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Container(
                width: 216,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    for (var i = 0; i < tabs.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 3,
                        ),
                        child: ListTile(
                          selected: selected == i,
                          selectedTileColor: theme.colorScheme.primaryContainer,
                          selectedColor: theme.colorScheme.onPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(icons[i], size: 22),
                          title: Text(labels[i]),
                          onTap: () => context.go('/${tabs[i]}'),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            child: Icon(
                              user.isMonk
                                  ? Icons.spa_outlined
                                  : Icons.person_outline,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user.isMonk ? 'သံဃာတော်' : 'အလှူရှင်',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.tab == 'calendar' ? 1120 : 840,
                  ),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: (value) => context.go('/${tabs[value]}'),
                destinations: [
                  for (var i = 0; i < tabs.length; i++)
                    NavigationDestination(
                      icon: Icon(icons[i]),
                      label: labels[i],
                    ),
                ],
              ),
            ),
    );
  }
}
