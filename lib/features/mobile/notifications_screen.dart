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
  final _scrollController = ScrollController();
  final List<Json> _items = [];
  int? _nextCursor;
  bool _hasNextPage = true;
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  String? _error;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      final result = await widget.repo.notificationsFeed(widget.userId, pageSize: 15);
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
      final result = await widget.repo.notificationsFeed(
        widget.userId,
        lastId: _nextCursor,
        pageSize: 15,
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
              tooltip: 'အားလုံးဖျက်ရန်',
              onPressed: busy ? null : _clear,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ],
        ),
      ),
      if (busy) const LinearProgressIndicator(),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: const [
                EmptyStateView(
                  icon: Icons.notifications_none_outlined,
                  title: 'အသိပေးချက် အသစ် မရှိပါ',
                  description:
                      'ဆွမ်းလှူဒါန်းမှုနှင့် ပတ်သက်သည့် အသိပေးချက်များ ရောက်ရှိလာပါက ဤနေရာတွင် ဖော်ပြပေးပါမည်။',
                ),
              ],
            )
          : ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + 1,
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return BottomLoadingIndicator(isLoading: _isLoadingMore);
                }

                final n = _items[index];
                return Dismissible(
                  key: ValueKey(n['id']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(20),
                    color: Theme.of(context).colorScheme.errorContainer,
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
                    setState(() {
                      _items.removeAt(index);
                    });
                    widget.onChanged();
                  },
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        color: n['isRead'] == true
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.primary,
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
                              if (ok) {
                                setState(() {
                                  n['isRead'] = true;
                                });
                                widget.onChanged();
                              }
                            },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _clear() async {
    if (!await confirmAction(context, 'အသိပေးချက်အားလုံး ဖျက်ရန်') ||
        !mounted) {
      return;
    }
    setState(() => busy = true);
    final ok = await runAction(context, () async {
      await widget.repo.call(
        'DELETE',
        '/api/v1/user/${widget.userId}/notification',
      );
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) {
      _reload();
    }
  }
}
