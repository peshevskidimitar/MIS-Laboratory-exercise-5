import 'package:exam_schedule/application_state.dart';
import 'package:exam_schedule/screens/calendar_screen.dart';
import 'package:exam_schedule/screens/map_screen.dart';
import 'package:exam_schedule/widgets/add_timetable_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/timetable_item.dart';

class TimetableScreen extends StatefulWidget {
  final List<TimetableItem> timetableItems;

  const TimetableScreen({super.key, required this.timetableItems});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {

  _addTimetableItem() {
    showDialog(
        context: context,
        builder: (context) {
          return Consumer<ApplicationState>(
              builder: (context, applicationState, _) {
            return AddTimetableItem(
                addTimetableItem: applicationState.addTimetableItemToTimetable);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, applicationState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Exam Timetable",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: _addTimetableItem,
                  child: const Icon(Icons.add),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Icon(Icons.logout),
                ),
              )
            ],
          ),
          body: Container(
            margin: const EdgeInsets.all(3),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemCount: widget.timetableItems.length,
              itemBuilder: (context, index) {
                return GridTile(
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.timetableItems[index].subject,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat("yyyy-MM-dd – kk:mm")
                              .format(widget.timetableItems[index].time),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.bottomRight,
                            child: FloatingActionButton(
                              heroTag: 'delete$index',
                              mini: true,
                              onPressed: () => applicationState
                                  .removeTimetableItemFromTimetable(
                                widget.timetableItems[index].id,
                              ),
                              child: const Icon(Icons.delete),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: Wrap(
            spacing: 10.0,
            children: [
              FloatingActionButton(
                heroTag: 'calendar',
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CalendarScreen(
                        timetableItems: widget.timetableItems,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.calendar_month),
              ),
              FloatingActionButton(
                heroTag: 'map',
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        timetableItems: widget.timetableItems,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.map),
              ),
            ],
          ),
        );
      },
    );
  }
}
