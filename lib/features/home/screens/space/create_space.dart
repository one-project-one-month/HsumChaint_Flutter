import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:hsum_chaint/presentation/widgets/custom_text_field.dart';
import 'package:hsum_chaint/presentation/widgets/primary_button.dart';
import 'package:hsum_chaint/utils/extensions/extensions.dart';
import 'package:hsum_chaint/utils/extensions/num_extensions.dart';

class CreateSpaceScreen extends StatefulWidget {
  const CreateSpaceScreen({super.key});

  @override
  State<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends State<CreateSpaceScreen> {
  static const _titleColor = Color(0xFF1E1A17);
  static const _sectionColor = Color(0xFF7A541D);
  static const _fieldBorderColor = Color(0xFFB9852B);
  static const _hintColor = Color(0xFF9B9B9B);
  static const _requiredColor = Color(0xFFFF4D4F);
  static const _buttonColor = Color(0xFFE8AE4F);

  final TextEditingController monasteryNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> phoneControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    monasteryNameController.dispose();
    addressController.dispose();
    emailController.dispose();
    for (final c in phoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _label(String text, {bool required = false, bool optional = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: _requiredColor),
            ),
          if (optional)
            const TextSpan(
              text: ' (optional)',
              style: TextStyle(
                color: Color(0xFF9B9B9B),
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _sectionColor,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return CustomInputTextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textStyle: const TextStyle(fontSize: 16, color: Colors.black),
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 16,
        color: _hintColor,
        fontWeight: FontWeight.w400,
      ),
      fillColor: Colors.transparent,
      borderColor: _fieldBorderColor,
      focusedBorderColor: _fieldBorderColor,
      borderRadius: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      showClearButton: false,
    );
  }

  Widget _avatarPicker() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 38,
              color: Color(0xFFA8A8A8),
            ),
          ),
          Positioned(
            right: -2,
            bottom: 10,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5EF),
                shape: BoxShape.circle,
                border: Border.all(color: _fieldBorderColor, width: 1),
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

  void _addPhoneField() {
    if (phoneControllers.length >= 4) return;
    setState(() {
      phoneControllers.add(TextEditingController());
    });
  }

  void _submit() {
    if (monasteryNameController.text.trim().isEmpty) {
      Get.snackbar('Required', 'Monastery name is required');
      return;
    }
    if (addressController.text.trim().isEmpty) {
      Get.snackbar('Required', 'Address is required');
      return;
    }
    if (phoneControllers.first.text.trim().isEmpty) {
      Get.snackbar('Required', 'Primary phone number is required');
      return;
    }

    Get.snackbar('Success', 'Space created');
  }

  @override
  Widget build(BuildContext context) {
    return
    // Scaffold(
    //   backgroundColor: _bgColor,
    //   body:
    SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Create Space',
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
            _avatarPicker(),
            28.h,

            _sectionTitle('Monastery Information'),
            22.h,

            _label('Monastery Name', required: true),
            10.h,
            _input(
              controller: monasteryNameController,
              hint: 'Enter monastery name',
            ),

            18.h,

            _label('Address', required: true),
            10.h,
            _input(
              controller: addressController,
              hint: 'Enter your address',
              maxLines: 4,
            ),

            26.h,

            _sectionTitle('Contact'),
            22.h,

            _label('Email', optional: true),
            10.h,
            _input(
              controller: emailController,
              hint: 'Enter email',
              keyboardType: TextInputType.emailAddress,
            ),

            18.h,

            Row(
              children: [
                Expanded(child: _label('Phone Number', required: true)),
                GestureDetector(
                  onTap: _addPhoneField,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _buttonColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.black),
                        SizedBox(width: 2),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            10.h,

            ...List.generate(phoneControllers.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == phoneControllers.length - 1 ? 0 : 12,
                ),
                child: _input(
                  controller: phoneControllers[index],
                  hint: index == 0
                      ? 'Primary Phone Number'
                      : 'Additional Phone Number',
                  keyboardType: TextInputType.phone,
                ),
              );
            }),

            10.h,
            const Text(
              'Add up to 4 contact numbers for the monastery.',
              style: TextStyle(fontSize: 14, color: Color(0xFF7C7C7C)),
            ),

            34.h,

            PrimaryButton(
              text: 'Create Space',
              isLoading: false,
              onPressed: _submit,
            ),

            20.h,
          ],
        ),
      ),
      //  ),
    ).screen(context: context);
  }
}
