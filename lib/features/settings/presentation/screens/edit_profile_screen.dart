import 'package:flutter/material.dart';
import 'package:hsum_chaint/utils/extensions/screen_extensions.dart';
import 'package:hsum_chaint/presentation/widgets/labelled_text_field.dart';
import 'package:hsum_chaint/presentation/widgets/settings_action_button.dart';
import 'package:hsum_chaint/presentation/widgets/top_glow.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'U Law Ti Ka');
  final _emailController = TextEditingController(text: 'lawtika@gmail.com');
  final _contactController = TextEditingController(text: '09422675753');
  final _addressController = TextEditingController(text: 'Min Ye Kyaw Swar Street');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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
                      _buildProfileImage(),
                      const SizedBox(height: 40),
                      LabelledTextField(
                        label: 'Name',
                        controller: _nameController,
                      ),
                      LabelledTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      LabelledTextField(
                        label: 'Contact No.',
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                      ),
                      LabelledTextField(
                        label: 'Address',
                        controller: _addressController,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildBottomButtons(),
      ],
    ).screen(context: context);
  }

  Widget _buildAppBar() {
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
            'Edit Profile',
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

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Color(0xFF9C6644)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1A17),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SettingsActionButton(
              text: 'Save',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
