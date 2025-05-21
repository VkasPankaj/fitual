import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;


  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    final sortedDates = history.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _showCalendar ? Icons.list : Icons.calendar_today,
              color: Theme.of(context).primaryColor,
              semanticLabel: _showCalendar ? 'Switch to list view' : 'Switch to calendar view',
            ),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
          IconButton(
            icon: Icon(
              Icons.upload,
              color: Theme.of(context).primaryColor,
              semanticLabel: 'Export to Google Fit',
            ),
            onPressed: (){},
            tooltip: 'Export to Google Fit',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return history.isEmpty
              ? Center(
                  child: Text(
                    'No workouts completed yet.',
                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                    semanticsLabel: 'No workouts completed',
                  ),
                )
              : _showCalendar
                  ? _buildCalendarView(history, constraints)
                  : _buildListView(history, sortedDates, constraints);
        },
      ),
    );
  }

  Widget _buildCalendarView(Map<String, List<String>> history, BoxConstraints constraints) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          eventLoader: (day) {
            final dateKey = DateFormat('yyyy-MM-dd').format(day);
            return history.containsKey(dateKey) ? history[dateKey]! : [];
          },
        ),
        if (_selectedDay != null) ...[
          Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.05),
            child: Text(
              DateFormat.yMMMMd().format(_selectedDay!),
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(constraints.maxWidth * 0.05),
              children: history[DateFormat('yyyy-MM-dd').format(_selectedDay!)]?.map((w) => ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          semanticLabel: 'Completed workout',
                        ),
                        title: Text(
                          w,
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ))?.toList() ??
                  [
                    Center(
                      child: Text(
                        'No workouts on this day',
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListView(Map<String, List<String>> history, List<String> sortedDates, BoxConstraints constraints) {
    return ListView.builder(
      padding: EdgeInsets.all(constraints.maxWidth * 0.05),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final workouts = history[dateKey]!;
        final formattedDate = DateFormat.yMMMMd().format(DateTime.parse(dateKey));

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: constraints.maxHeight * 0.02),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              leading: Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
                semanticLabel: 'Date icon',
              ),
              title: Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: workouts
                  .map((w) => ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          semanticLabel: 'Completed workout',
                        ),
                        title: Text(
                          w,
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}