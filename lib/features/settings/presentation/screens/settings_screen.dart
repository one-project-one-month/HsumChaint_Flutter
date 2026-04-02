import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/utils/extensions/screen_extensions.dart';
import 'package:hsum_chaint/presentation/widgets/setting_item.dart';
import 'package:hsum_chaint/presentation/widgets/setting_section.dart';
import 'package:hsum_chaint/presentation/widgets/top_glow.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              const Positioned(top: 0, left: 0, right: 0, child: TopGlow()),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildAppBar(),
                      const SizedBox(height: 32),
                       _buildProfileHeader(context),
                      const SizedBox(height: 40),
                      _buildAccountSection(context),
                      _buildPreferencesSection(),
                      _buildScheduleSection(),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildBottomNavBar(),
      ],
    ).screen(context: context);
  }

  Widget _buildAppBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1A17),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.profilePath),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                'assets/uzine.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF7A541D),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'U Law Ti Ka',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1A17),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '+95 9 422 675 753',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6F6A66),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return SettingSection(
      title: 'Account',
      children: [
        SettingItem(
          icon: Icons.edit_outlined,
          iconBackgroundColor: Colors.blue,
          title: 'Edit Profile',
          onTap: () => context.push(AppRoutes.profilePath),
        ),
        SettingItem(
          icon: Icons.lock_outline,
          iconBackgroundColor: Colors.green,
          title: 'Change Password',
          onTap: () {},
        ),
        SettingItem(
          icon: Icons.person_remove_outlined,
          iconBackgroundColor: Colors.red,
          title: 'Delete Account',
          isDestructive: true,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return SettingSection(
      title: 'Preferences',
      children: [
        SettingItem(
          icon: Icons.notifications_none_outlined,
          iconBackgroundColor: Colors.indigo,
          title: 'Notifications',
          onTap: () {},
        ),
        SettingItem(
          icon: Icons.language_outlined,
          iconBackgroundColor: Colors.amber,
          title: 'Language',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return SettingSection(
      title: 'Schedule',
      children: [
        SettingItem(
          icon: Icons.alarm_outlined,
          iconBackgroundColor: Colors.orange,
          title: 'Schedule Reminder',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_outlined, size: 20),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    // Basic bottom nav mimicking the design for visual consistency
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 35),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0E5D8), width: 1)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
          _buildNavItem(Icons.calendar_month_outlined, 'Calendar', false),
          _buildNavItem(Icons.settings, 'Settings', true),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 18 : 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0D9AF) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF7A541D) : const Color(0xFF1F1A17),
            size: 28,
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A541D),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
