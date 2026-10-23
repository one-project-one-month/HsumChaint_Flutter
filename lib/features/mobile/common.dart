import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String dateLabel(DateTime? date) => date == null
    ? 'အချိန် မသတ်မှတ်ရသေးပါ'
    : DateFormat('dd MMM yyyy • HH:mm').format(date.toLocal());

class LoadView<T> extends StatelessWidget {
  final Future<T> future;
  final VoidCallback retry;
  final Widget Function(T data) builder;
  const LoadView({
    super.key,
    required this.future,
    required this.retry,
    required this.builder,
  });
  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 36),
                const SizedBox(height: 12),
                Text(snapshot.error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: retry,
                  child: const Text('ပြန်ကြိုးစားရန်'),
                ),
              ],
            ),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting ||
          !snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return builder(snapshot.data as T);
    },
  );
}

Widget emptyMessage(String text) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
  child: Center(child: Text(text, textAlign: TextAlign.center)),
);

Future<bool> confirmAction(BuildContext context, String title) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('ဤလုပ်ဆောင်ချက်ကို အတည်ပြုပါသလား။'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('မလုပ်တော့ပါ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('အတည်ပြုမည်'),
          ),
        ],
      ),
    ) ??
    false;

Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('လုပ်ဆောင်ပြီးပါပြီ။')));
    }
    return true;
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
    return false;
  }
}

Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
}) async {
  final current = (initial ?? DateTime.now()).toLocal();
  final date = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100, 12, 31),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(current),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
