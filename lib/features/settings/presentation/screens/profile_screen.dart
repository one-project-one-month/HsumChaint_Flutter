import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/utils/extensions/screen_extensions.dart';
import 'package:hsum_chaint/presentation/widgets/profile_info_row.dart';
import 'package:hsum_chaint/presentation/widgets/setting_section.dart';
import 'package:hsum_chaint/presentation/widgets/settings_action_button.dart';
import 'package:hsum_chaint/presentation/widgets/top_glow.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                      _buildAppBar(context),
                      const SizedBox(height: 32),
                      _buildProfileImage(),
                      const SizedBox(height: 40),
                      SettingSection(
                        title: 'Personal Information',
                        children: const [
                          ProfileInfoRow(label: 'Name', value: 'U Law Ti Ka'),
                          ProfileInfoRow(label: 'Role', value: 'Owner'),
                        ],
                      ),
                      SettingSection(
                        title: 'Contact Information',
                        children: const [
                          ProfileInfoRow(label: 'Phone', value: '09 422 675 753'),
                          ProfileInfoRow(label: 'Email', value: 'lawtika@gmail.com'),
                          ProfileInfoRow(label: 'Address', value: 'Min Ye Kyaw Swar Street'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildBottomButton(context),
      ],
    ).screen(context: context);
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.chevron_left, size: 32, color: Color(0xFF1F1A17)),
            ),
          ),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1A17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF7D6B8),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/uzine.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 24,
              color: Color(0xFF1F1A17),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: SettingsActionButton(
        text: 'Edit',
        onPressed: () => context.push(AppRoutes.editProfilePath),
      ),
    );
  }
}
