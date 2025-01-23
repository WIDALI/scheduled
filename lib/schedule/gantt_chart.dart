import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'algorithms.dart';

class GanttChartFramework extends StatefulWidget {
  final List<ScheduledProcess> schedulingResult;
  final Map<int, String> taskNames;
  final String algorithmName;
  final int startTime;
  final double quantumTime;

  const GanttChartFramework({
    Key? key,
    required this.schedulingResult,
    required this.taskNames,
    required this.algorithmName,
    required this.startTime,
    this.quantumTime = 0.5,
  }) : super(key: key);

  @override
  GanttChartInterface createState() => GanttChartInterface();
}

class GanttChartInterface extends State<GanttChartFramework> {
  final Map<int, Color> taskColors = {};

  Color generateComplementaryColor(int pid) {
    if (!taskColors.containsKey(pid)) {
      final random = Random();
      final baseColor = Color.fromARGB(
        255,
        random.nextInt(200),
        random.nextInt(200),
        random.nextInt(200),
      );
      taskColors[pid] = baseColor.withOpacity(0.8); //again???
    }
    return taskColors[pid]!;
  }

  String formatTime(int minutesFromStart) {
    final int startHours = minutesFromStart ~/ 60;
    final int startMinutes = minutesFromStart % 60;
    return "${startHours.toString().padLeft(2, '0')}:${startMinutes.toString().padLeft(2, '0')}";
  }

  void showTaskDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Task Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.schedulingResult.map((process) {
                final taskName =
                    widget.taskNames[process.pid] ?? 'Task ${process.pid}';
                final startTimeFormatted = formatTime(process.startTime);
                final endTimeFormatted = formatTime(process.endTime);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "$taskName: $startTimeFormatted - $endTimeFormatted",
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

//NOYE: I hate indentssss!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EE),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back arrow
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
              // Algorithm Name 
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAD5CA),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    widget.algorithmName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Gantt Chart Title
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DED6),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Text(
                    "Gantt Chart",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Gantt Chart Visualisation
              Center(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      height: 100,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: widget.schedulingResult.map((process) {
                          return Expanded(
                            flex: (process.endTime - process.startTime),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              color: generateComplementaryColor(process.pid),
                              child: Center(
                                child: Text(
                                  widget.taskNames[process.pid] ??
                                      'Task ${process.pid}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Times at the end of blocks
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: widget.schedulingResult.map((process) {
                          return Expanded(
                            flex: (process.endTime - process.startTime),
                            child: Align(
                              alignment: Alignment
                                  .centerRight, 
                              child: Text(
                                formatTime(process.endTime), 
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // Footer Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: GestureDetector(
                  onTap: showTaskDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAD5CA),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      "Task Details",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
