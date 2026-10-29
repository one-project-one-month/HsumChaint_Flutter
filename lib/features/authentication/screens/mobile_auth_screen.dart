import '../../../presentation/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

class MobileAuthScreen extends StatefulWidget {
  final bool register, monk;
  const MobileAuthScreen({super.key, this.register = false, this.monk = false});
  @override
  State<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final _form = GlobalKey<FormState>();
  final auth = Get.find<AuthController>();
  late bool _monk = widget.monk;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  const Center(child: AppLogo(size: 88)),
                  const SizedBox(height: 16),
                  Text(
                    'Hsum Chaint (ဆွမ်းချိုင့်)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'သဒ္ဓါတရားဖြင့် ဆွမ်းကပ်လှူကြပါစို့',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('ဝင်ရန်')),
                      ButtonSegment(value: true, label: Text('အကောင့်သစ်')),
                    ],
                    selected: {widget.register},
                    onSelectionChanged: (value) {
                      auth.clearControllers();
                      context.go(value.first ? '/user_signup' : '/login');
                    },
                  ),
                  const SizedBox(height: 24),
                  if (widget.register) ...[
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('အလှူရှင်'),
                          icon: Icon(Icons.volunteer_activism_outlined),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('သံဃာတော်'),
                          icon: Icon(Icons.temple_buddhist_outlined),
                        ),
                      ],
                      selected: {_monk},
                      onSelectionChanged: (v) =>
                          setState(() => _monk = v.first),
                    ),
                    const SizedBox(height: 20),
                    _field('အမည်', auth.usernameController, required: true),
                  ],
                  _field(
                    'ဖုန်းနံပါတ်',
                    auth.phoneController,
                    required: true,
                    keyboard: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: auth.passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'စကားဝှက်',
                      suffixIcon: IconButton(
                        tooltip: 'စကားဝှက် ပြမည် / ဝှက်မည်',
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'ကျေးဇူးပြု၍ ဖြည့်စွက်ပေးပါ။'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (widget.register) ...[
                    TextFormField(
                      controller: auth.confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'စကားဝှက် အတည်ပြုရန်',
                      ),
                      validator: (v) => v != auth.passwordController.text
                          ? 'စကားဝှက်နှစ်ခု တူညီမှု မရှိပါ။'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      'အီးမေးလ် (ရှိပါက)',
                      auth.emailController,
                      keyboard: TextInputType.emailAddress,
                    ),
                    if (_monk) ...[
                      _field(
                        'ကျောင်းတိုက်အမည်',
                        auth.monasteryNameController,
                        required: true,
                      ),
                      _field(
                        'ကျောင်းတိုက်လိပ်စာ',
                        auth.monasteryAddressController,
                        required: true,
                      ),
                    ] else
                      _field(
                        'ဆက်သွယ်ရန်ဖုန်း (ရှိပါက)',
                        auth.contactPhoneController,
                        keyboard: TextInputType.phone,
                      ),
                  ],
                  Obx(
                    () => FilledButton(
                      onPressed: auth.isLoading.value ? null : _submit,
                      child: auth.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.register
                                  ? 'အကောင့်ဖွင့်ရန်'
                                  : 'ဝင်ရောက်ရန်',
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType keyboard = TextInputType.text,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label),
      validator: (v) => required && (v == null || v.trim().isEmpty)
          ? 'ကျေးဇူးပြု၍ ဖြည့်စွက်ပေးပါ။'
          : null,
    ),
  );

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!widget.register) {
      await auth.login();
      return;
    }
    final success = _monk ? await auth.signupMonk() : await auth.signupUser();
    if (success && mounted) {
      auth.clearControllers();
      context.go('/login');
    }
  }
}
