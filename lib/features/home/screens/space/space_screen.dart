import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hsum_chaint/core/navigation/app_routes.dart';
import 'package:hsum_chaint/utils/extensions/extensions.dart';
import 'package:table_calendar/table_calendar.dart';

enum SpaceTab { donorList, reminder, events }

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  static const _textColor = Color(0xFF1F1A17);
  static const _mutedText = Color(0xFF8C8C8C);
  static const _brown = Color(0xFF6F3A06);
  static const _accent = Color(0xFFC56A08);
  static const _lineColor = Color(0xFFE1D8CA);

  DateTime _focusedDay = DateTime(2026, 3, 17);
  DateTime? _selectedDay = DateTime(2026, 3, 17);
  CalendarFormat _calendarFormat = CalendarFormat.week;
  SpaceTab _selectedTab = SpaceTab.donorList;

  final List<Map<String, String>> _donorLists = const [
    {'title': 'Title', 'date': 'Tuesday, March 17, 05:00 AM'},
    {'title': 'Title', 'date': 'Tuesday, March 17, 05:00 AM'},
  ];

  final List<Map<String, String>> _reminders = const [
    {'title': 'Transport Hsun Chaint', 'date': 'Tuesday, March 17, 03:00 PM'},
    {'title': 'Offer rice donation', 'date': 'Tuesday, March 17, 08:30 AM'},
    {'title': 'Prepare donation space', 'date': 'Tuesday, March 17, 10:00 AM'},
  ];

  final List<Map<String, String>> _events = const [
    {
      'day': '19',
      'title': 'Full Moon Day Invitation',
      'date': 'Thursday, March 2026',
      'desc': 'Lorem ipsum dolor sit amet consectetur.',
    },
    {
      'day': '21',
      'title': 'Full Moon Day Invitation',
      'date': 'Thursday, March 2026',
      'desc': 'Lorem ipsum dolor sit amet consectetur.',
    },
    {
      'day': '28',
      'title': 'Full Moon Day Invitation',
      'date': 'Thursday, March 2026',
      'desc': 'Lorem ipsum dolor sit amet consectetur.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
                const Expanded(
                  child: Text(
                    'Space',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.spaceInfoScreenPath),
                  icon: const Icon(Icons.tune, size: 24),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: _lineColor),
                  const SizedBox(height: 14),
                  _buildTabs(),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _lineColor),
                  const SizedBox(height: 18),
                  _buildActionButton(),
                  const SizedBox(height: 18),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    ).screen(context: context);
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2035, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
          leftChevronIcon: _calendarChevron(Icons.chevron_left),
          rightChevronIcon: _calendarChevron(Icons.chevron_right),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12,
            color: _mutedText,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            fontSize: 12,
            color: _mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          isTodayHighlighted: false,
          defaultTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
          weekendTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
          selectedTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          selectedDecoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(12),
          ),
          cellMargin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          cellPadding: EdgeInsets.zero,
          defaultDecoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          weekendDecoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        availableCalendarFormats: const {
          CalendarFormat.week: 'Week',
          CalendarFormat.month: 'Month',
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final text = [
              'Sun',
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
            ][day.weekday % 7];
            return Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: _mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _calendarChevron(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5DED2)),
      ),
      child: Icon(icon, size: 22, color: _textColor),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: _tabButton(
            label: 'Donor List',
            icon: Icons.group_outlined,
            selected: _selectedTab == SpaceTab.donorList,
            onTap: () => setState(() => _selectedTab = SpaceTab.donorList),
          ),
        ),
        Expanded(
          child: _tabButton(
            label: 'Reminder',
            icon: Icons.access_time,
            selected: _selectedTab == SpaceTab.reminder,
            onTap: () => setState(() => _selectedTab = SpaceTab.reminder),
          ),
        ),
        Expanded(
          child: _tabButton(
            label: 'Events',
            icon: Icons.auto_awesome,
            selected: _selectedTab == SpaceTab.events,
            onTap: () => setState(() => _selectedTab = SpaceTab.events),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    String text;
    switch (_selectedTab) {
      case SpaceTab.donorList:
        text = 'Create Donor List';
        break;
      case SpaceTab.reminder:
        text = 'Add Reminder';
        break;
      case SpaceTab.events:
        return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        side: const BorderSide(color: _brown, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.add, color: _textColor),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: _textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case SpaceTab.donorList:
        return Column(
          children: _donorLists
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _DonorListCard(
                    title: item['title']!,
                    date: item['date']!,
                    onEdit: () {},
                    onDelete: () {},
                  ),
                ),
              )
              .toList(),
        );

      case SpaceTab.reminder:
        return Column(
          children: _reminders
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReminderCard(
                    title: item['title']!,
                    date: item['date']!,
                  ),
                ),
              )
              .toList(),
        );

      case SpaceTab.events:
        return Column(
          children: _events
              .map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _EventCard(
                    day: event['day']!,
                    title: event['title']!,
                    date: event['date']!,
                    description: event['desc']!,
                  ),
                ),
              )
              .toList(),
        );
    }
  }

  Widget _tabButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: selected ? _brown : _textColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? _brown : _textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 3, color: selected ? _brown : Colors.transparent),
      ],
    );
  }
}

class _DonorListCard extends StatelessWidget {
  const _DonorListCard({
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
  static const _brown = Color(0xFF6F3A06);
  static const _textColor = Color(0xFF1F1A17);
  static const _editBlue = Color(0xFF0057D8);
  static const _deleteRed = Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
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
                    color: _brown,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 24,
                  color: _editBlue,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 24,
                  color: _deleteRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Donors : ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _brown,
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
                  border: Border.all(color: _brown),
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
          Text(date, style: const TextStyle(fontSize: 14, color: _brown)),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.title, required this.date});

  final String title;
  final String date;

  static const _cardColor = Color(0xFFF2DEB8);
  static const _textColor = Color(0xFF1F1A17);
  static const _brown = Color(0xFF6F3A06);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFF8F5EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time, color: _textColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 14, color: _brown)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: _brown),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.day,
    required this.title,
    required this.date,
    required this.description,
  });

  final String day;
  final String title;
  final String date;
  final String description;

  static const _cardColor = Color(0xFFF2DEB8);
  static const _brown = Color(0xFF6F3A06);
  static const _textColor = Color(0xFF1F1A17);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _brown,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: _brown,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(fontSize: 14, color: _textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: _brown),
                ),
              ],
            ),
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
        border: Border.all(color: const Color(0xFF6F3A06)),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 18,
        color: Color(0xFF6F3A06),
      ),
    );
  }
}
