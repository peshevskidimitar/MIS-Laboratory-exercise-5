import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/notifications/local_notifications_manager.dart';
import '../services/locations/locations.dart';

class AddTimetableItem extends StatefulWidget {
  final FutureOr<void> Function(String subject, DateTime time, String location)
      addTimetableItem;

  const AddTimetableItem({super.key, required this.addTimetableItem});

  @override
  State<AddTimetableItem> createState() => _AddTimetableItemState();
}

class _AddTimetableItemState extends State<AddTimetableItem> {
  final _subjectController = TextEditingController();
  DateTime dateTime = DateTime.now();
  String selectedLocation = 'Laboratory 1';

  void _submitData() async {
    if (_subjectController.text.isEmpty) return;
    widget.addTimetableItem(
        _subjectController.text, dateTime, selectedLocation);
    Navigator.pop(context);
    await localNotificationsManager.scheduleNotification(
        LocalNotification(
          Random().nextInt(1000),
          '${_subjectController.text} - Exam',
          'Tomorrow you have an exam in ${_subjectController.text} at ${DateFormat("kk:mm").format(dateTime)}.',
          null,
        ),
        dateTime.subtract(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    List<String> locations = [
      'Laboratory 1',
      'Laboratory 2',
      'Laboratory 3',
      'Laboratory 4',
      'Laboratory 5',
      'Laboratory 6',
      'Laboratory 7',
      'Laboratory 8',
      'Laboratory 9',
      'Laboratory 10',
    ];

    return AlertDialog(
      title: const Text("New Exam"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: "Subject"),
            onSubmitted: (_) {},
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final date = await pickDate();
                    if (date == null) return;
                    final time = await pickTime();
                    if (time == null) return;

                    final dateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                      0,
                      0,
                      0,
                    );
                    setState(() => this.dateTime = dateTime);
                  },
                  child:
                      Text(DateFormat("yyyy-MM-dd – kk:mm").format(dateTime)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownMenu(
            initialSelection: locations.first,
            onSelected: (String? value) {
              setState(() {
                selectedLocation = value!;
              });
            },
            dropdownMenuEntries:
                locations.map<DropdownMenuEntry<String>>((String value) {
              return DropdownMenuEntry<String>(value: value, label: value);
            }).toList(),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitData,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      );
}
