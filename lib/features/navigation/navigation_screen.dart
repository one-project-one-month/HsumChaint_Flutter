import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:hsum_chaint/features/home/screens/home_screen.dart';
import 'package:hsum_chaint/features/navigation/navigation_controller.dart';
import 'package:hsum_chaint/features/settings/presentation/screens/settings_screen.dart';

class NavigationScreen extends GetView<NavigationController> {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(),
      Container(),
      Container(),
      // ProfileScreen(),
      // CalendarScreen(),
      SettingsScreen(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavItem(icon: Icons.home_filled, label: 'Home'),
            BottomNavItem(icon: Icons.person_outline, label: 'Donors'),
            BottomNavItem(
              icon: Icons.calendar_month_outlined,
              label: 'Calendar',
            ),
            BottomNavItem(icon: Icons.settings_outlined, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label});
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  static const _navBg = Color(0xFFF3EFE8);
  static const _activeNavBg = Color(0xFFF0D9AF);
  static const _textColor = Color(0xFF1F1A17);
  static const _primaryBrown = Color(0xFF7A541D);

  @override
  Widget build(BuildContext context) {
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
                    items[index].icon,
                    color: isActive ? _primaryBrown : _textColor,
                    size: 28,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Text(
                      items[index].label,
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
