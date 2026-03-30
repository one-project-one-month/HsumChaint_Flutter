import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/utils/extensions/screen_extensions.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const _textColor = Color(0xFF1F1A17);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          /// App Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
                const Expanded(
                  child: Text(
                    'Notification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, size: 22),
                ),
              ],
            ),
          ),

          /// Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                SizedBox(height: 10),

                /// Today
                _DateHeader('Today'),
                SizedBox(height: 16),

                _NotificationCard(
                  title: 'Transport Hsun Chaint',
                  subtitle: '03:00 PM',
                  time: '3 min ago',
                  icon: Icons.access_time,
                ),

                SizedBox(height: 12),

                _NotificationCard(
                  title: 'Someone Joined !',
                  subtitle: 'New member joined your space.',
                  time: '3 min ago',
                  icon: Icons.send_outlined,
                ),

                SizedBox(height: 24),

                /// Older Date
                _DateHeader('12 Jan 2026'),
                SizedBox(height: 16),

                _NotificationCard(
                  title: 'Transport Hsun Chaint',
                  subtitle: '03:00 PM',
                  time: '1 day ago',
                  icon: Icons.access_time,
                ),

                SizedBox(height: 12),

                _NotificationCard(
                  title: 'Someone Joined !',
                  subtitle: 'New member joined your space.',
                  time: '1 day ago',
                  icon: Icons.send_outlined,
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    ).screen(context: context);
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F1A17),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          /// Icon Circle
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F5EF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: _textColor),
          ),

          const SizedBox(width: 14),

          /// Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 13, color: _mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: _textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
