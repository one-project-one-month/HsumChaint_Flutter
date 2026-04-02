import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/utils/extensions/screen_extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _primaryBrown = Color(0xFF7A541D);
  static const _textColor = Color(0xFF1F1A17);

  int _currentIndex = 0;

  final List<Map<String, String>> _notifications = const [
    {
      'title': 'Transport Hsun Chaint',
      'subtitle': '03:00 PM',
      'time': '3 min ago',
      'type': 'clock',
    },
    {
      'title': 'Someone Joined !',
      'subtitle': 'New member joined your space.',
      'time': '3 min ago',
      'type': 'send',
    },
  ];

  final List<Map<String, String>> _donorList = const [
    {'title': 'Title', 'date': 'Tuesday, March 17, 05:00 AM'},
    {'title': 'Title', 'date': 'Tuesday, March 17, 05:00 AM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              const Positioned(top: 0, left: 0, right: 0, child: _TopGlow()),
              SafeArea(
                child: SingleChildScrollView(
                  // padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                        child: _buildHeader(),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Text(
                          '19 March, 2026 Thursday',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildSectionContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              title: 'Recent Notification',
                              onSeeAll: () =>
                                  context.push(AppRoutes.notificationPath),
                            ),
                            const SizedBox(height: 18),
                            ..._notifications.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NotificationCard(
                                  title: item['title']!,
                                  subtitle: item['subtitle']!,
                                  time: item['time']!,
                                  icon: item['type'] == 'clock'
                                      ? Icons.access_time_rounded
                                      : Icons.send_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Feature Categories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _textColor,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _FeatureCard(
                                    icon: Icons.layers_outlined,
                                    title: 'Space',
                                    onTap: () =>
                                        context.push(AppRoutes.spaceScreenPath),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: _FeatureCard(
                                    icon: Icons.calendar_month_outlined,
                                    title: 'Calendar',
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _buildSectionHeader(
                              title: 'Today Donor List',
                              onSeeAll: () {},
                            ),
                            const SizedBox(height: 18),
                            ..._donorList
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _DonorCard(
                                      title: item['title']!,
                                      date: item['date']!,
                                      onEdit: () {},
                                      onDelete: () {},
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ],
    ).screen(context: context);
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF7D6B8),
          ),
          child: ClipOval(
            child: Image.network(
              'https://via.placeholder.com/48x48.png?text=%20',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, color: _primaryBrown),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mingalarpr !',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ashin Thila Ouda',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(AppRoutes.notificationPath),
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _primaryBrown,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: _primaryBrown),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopGlow extends StatelessWidget {
  const _TopGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.1),
          radius: 1.35,
          colors: [Color(0xFFF2CC87), Color(0x99F2CC87), Color(0x00F2CC87)],
          stops: [0.15, 0.58, 1.0],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  static const _cardColor = Color(0xFFF2DEB8);
  static const _textColor = Color(0xFF1F1A17);
  static const _mutedText = Color(0xFF6F6A66);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F5EF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _textColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: _textColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: _mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  static const _cardColor = Color(0xFFF2DEB8);
  static const _textColor = Color(0xFF1F1A17);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 105,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: _textColor),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonorCard extends StatelessWidget {
  const _DonorCard({
    required this.title,
    required this.date,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String date;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _cardColor = Color(0xFFF2DEB8);
  static const _textColor = Color(0xFF1F1A17);
  static const _primaryBrown = Color(0xFF7A541D);
  static const _editBlue = Color(0xFF0057D8);
  static const _deleteRed = Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _primaryBrown,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: _editBlue,
                  size: 24,
                ),
              ),

              IconButton(
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete_outline,
                  color: _deleteRed,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Donors : ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primaryBrown,
                ),
              ),
              ...List.generate(
                3,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: _MiniAvatar(),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5EF),
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryBrown, width: 1),
                ),
                child: const Text(
                  '2+',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            date,
            style: const TextStyle(fontSize: 14, color: _primaryBrown),
          ),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF7A541D), width: 1),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 18,
        color: Color(0xFF7A541D),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _navBg = Color(0xFFF3EFE8);
  static const _activeNavBg = Color(0xFFF0D9AF);
  static const _textColor = Color(0xFF1F1A17);
  static const _primaryBrown = Color(0xFF7A541D);

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_filled, 'Home'),
      (Icons.person_outline, 'Profile'),
      (Icons.calendar_month_outlined, 'Calendar'),
      (Icons.settings_outlined, 'Settings'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        color: _navBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 18 : 12,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isActive ? _activeNavBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    items[index].$1,
                    color: isActive ? _primaryBrown : _textColor,
                    size: 28,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Text(
                      items[index].$2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _primaryBrown,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
