import 'package:flutter/material.dart';
import '../../data/models/mobile_models.dart';
import '../../data/repositories/mobile_repository.dart';
import 'common.dart';

class NotificationsScreen extends StatefulWidget {
  final MobileRepository repo;
  final int userId;
  final VoidCallback onChanged;
  const NotificationsScreen({
    super.key,
    required this.repo,
    required this.userId,
    required this.onChanged,
  });
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int page = 1;
  bool busy = false;
  late Future<PageData<Json>> future;
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    future = widget.repo.list(
      '/api/user/${widget.userId}/notification',
      page: page,
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                'အသိပေးချက်များ',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'ပြန်တင်ရန်',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'အားလုံးဖျက်ရန်',
              onPressed: busy ? null : _clear,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ],
        ),
      ),
      if (busy) const LinearProgressIndicator(),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (result.items.isEmpty) emptyMessage('အသိပေးချက် မရှိသေးပါ။'),
                for (final n in result.items)
                  Dismissible(
                    key: ValueKey(n['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(20),
                      color: Colors.red.shade100,
                      child: const Icon(Icons.delete_outline),
                    ),
                    confirmDismiss: (_) async {
                      if (busy ||
                          !await confirmAction(context, 'အသိပေးချက်ဖျက်ရန်') ||
                          !context.mounted) {
                        return false;
                      }
                      return runAction(
                        context,
                        () => widget.repo.notification(
                          n['id'],
                          widget.userId,
                          delete: true,
                        ),
                      );
                    },
                    onDismissed: (_) {
                      result.items.remove(n);
                      _reload();
                    },
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          n['isRead'] == true
                              ? Icons.notifications_none
                              : Icons.notifications_active_outlined,
                        ),
                        title: Text(
                          n['message'] ?? '',
                          style: TextStyle(
                            fontWeight: n['isRead'] == true
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          dateLabel(DateTime.tryParse(n['createdAt'] ?? '')),
                        ),
                        onTap: busy || n['isRead'] == true
                            ? null
                            : () async {
                                setState(() => busy = true);
                                final ok = await runAction(
                                  context,
                                  () => widget.repo.notification(
                                    n['id'],
                                    widget.userId,
                                  ),
                                );
                                if (!mounted) return;
                                setState(() => busy = false);
                                if (ok) _reload();
                              },
                      ),
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
      ),
    ],
  );
  Future<void> _clear() async {
    if (!await confirmAction(context, 'အသိပေးချက်အားလုံး ဖျက်ရန်') ||
        !mounted) {
      return;
    }
    setState(() => busy = true);
    final ok = await runAction(context, () async {
      await widget.repo.call(
        'DELETE',
        '/api/user/${widget.userId}/notification',
      );
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) {
      page = 1;
      _reload();
    }
  }
}
