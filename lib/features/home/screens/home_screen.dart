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
      'ကိုယ်ရေး',
    ];
    final icons = [
      Icons.calendar_month_outlined,
      Icons.volunteer_activism_outlined,
      Icons.temple_buddhist_outlined,
      Icons.notifications_outlined,
      Icons.person_outline,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hsum Chaint (ဆွမ်းချိုင့်)',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              '${user.name} · ${user.isMonk ? 'သံဃာတော်' : 'အလှူရှင်'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (widget.tab != 'donations')
          IconButton(
            tooltip: 'အသိပေးချက်',
            onPressed: () => context.go('/notifications'),
            icon: Badge(
              isLabelVisible: _unread > 0,
              label: Text('$_unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: LoadView(
              future: _mine,
              retry: _refresh,
              builder: (mine) {
                return switch (widget.tab) {
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
                };
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        height: 76,
        onDestinationSelected: (value) => context.go('/${tabs[value]}'),
        destinations: [
          for (var i = 0; i < tabs.length; i++)
            NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
        ],
      ),
    );
  }
}
