import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/presentation/widgets/primary_button.dart';
import 'package:hsum_chaint/utils/extensions/extensions.dart';

class SpaceInfoScreen extends StatelessWidget {
  const SpaceInfoScreen({super.key});

  static const _titleColor = Color(0xFF1E1A17);
  static const _sectionColor = Color(0xFF7A541D);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Space Info',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            26.h,

            /// Avatar
            _AvatarPicker(),

            32.h,

            /// Monastery Info
            const Text(
              'Monastery Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _sectionColor,
              ),
            ),

            22.h,

            const _InfoItem(label: 'Monastery Name', value: 'Monastery Name'),

            24.h,

            const _InfoItem(
              label: 'Monastery Address',
              value:
                  'Lorem ipsum dolor sit amet consectetur. Id consectetur massa mi vivamus aliquet.',
            ),

            30.h,

            /// Contact
            const Text(
              'Contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _sectionColor,
              ),
            ),

            22.h,

            const _InfoItem(label: 'Email', value: 'www.example@gmail.com'),

            24.h,

            const _InfoItem(label: 'Phone Number', value: '+959987654321'),

            const Spacer(),

            /// Button
            PrimaryButton(
              text: 'Edit Info',
              isLoading: false,
              onPressed: () {
                // context.push('/edit-space');
              },
            ),

            6.h,
          ],
        ),
      ),
    ).screen(context: context);
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  static const _labelColor = Color(0xFF9B9B9B);
  static const _textColor = Color(0xFF1F1A17);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            height: 1.4,
            fontWeight: FontWeight.w400,
            color: _textColor,
          ),
        ),
      ],
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker();

  static const _borderColor = Color(0xFFB9852B);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 48,
              color: Color(0xFFA8A8A8),
            ),
          ),

          /// Small camera button
          Positioned(
            right: 0,
            bottom: 10,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5EF),
                shape: BoxShape.circle,
                border: Border.all(color: _borderColor),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                onPressed: () {},
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
