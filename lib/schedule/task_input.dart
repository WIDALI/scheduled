import 'dart:core';
import 'package:flutter/material.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'algorithms.dart';
import 'gantt_chart.dart';
import '../widgets/quantum_time.dart';
import 'algorithmInput.dart';

class TaskInputFramework extends StatefulWidget {
  const TaskInputFramework({super.key});

  @override
  State<TaskInputFramework> createState() => TaskInputInterface();
}

class TaskInputInterface extends State<TaskInputFramework> {
  String? selectedAlgorithm; // still needed to store the algorithm name
  final List<Map<String, dynamic>> tasks = [];

  List<String?> slots = List.generate(5, (_) => null);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController studyTimeController = TextEditingController();
  final TextEditingController priorityChangeController =
      TextEditingController();
  final TextEditingController preemptionRuleController =
      TextEditingController();
  final TextEditingController startTimeController = TextEditingController();

  bool isStartTimeSet = false;

  // dropdown data for categories
  final List<String> categories = [
    "Assignments",
    "Coursework",
    "Group Work",
    "Exams/Quizzes",
    "Practical Work"
  ];
  final Map<String, int> effortMapping = {
    "Assignments": 1,
    "Coursework": 2,
    "Group Work": 3,
    "Exams/Quizzes": 4,
    "Practical Work": 5
  };

  String? selectedCategory; //  needed to store the selected category

  @override
  void initState() {
    super.initState();
    _loadSelectedAlgorithm();
    _loadQuantumTime();
    _loadSlots();
  }

  Future<void> _loadSelectedAlgorithm() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAlgorithm = prefs.getString('selectedAlgorithm');
      //print("Loaded Algorithm: $selectedAlgorithm"); // Debugging step
    });
  }

  Future<void> _loadQuantumTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studyTimeController.text = prefs.getDouble('quantumTime')?.toString() ??
          "0.5"; // default -> 30 mins
      //print("Loaded Quantum Time: ${studyTimeController.text}");
    });
  }

  Future<void> _loadSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSlots = prefs.getStringList('categorySlots') ?? [];
    setState(() {
      slots = savedSlots.map((slot) => slot.isEmpty ? null : slot).toList();
    });
    //print("Loaded Slots: $slots"); // Debugging
  }

  void saveTask() {
    final String name = nameController.text;
    final double duration = double.tryParse(durationController.text) ?? 0.0;
    final String startTimeText = startTimeController.text;

    // parse the start time from the text
    DateTime startTime;

    if (startTimeText.isEmpty) {// If start time empty -> current time = default
      startTime = DateTime.now();
    } else {
      try {
        startTime = DateFormat("HH:mm").parse(startTimeText);
      } catch (e) {
        // snack bar error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid time format. Please use HH:mm.')),
        );
        return;
      }
    }

    final int startTimeInMinutes = startTime.hour * 60 + startTime.minute;

    // task object
    final Map<String, dynamic> task = {
      "pid": tasks.length + 1, 
      "Assignment Name": name,
      "Duration": duration,
      "Start Time": startTimeInMinutes,

      if (AlgorithmInput.contains(selectedAlgorithm!, "Priority"))
        "Priority": priorityController.text.isNotEmpty
            ? int.tryParse(priorityController.text)
            : null,
      if (AlgorithmInput.contains(selectedAlgorithm!, "Deadline"))
        "Deadline": deadlineController.text,
      if (AlgorithmInput.contains(selectedAlgorithm!, "Category"))
        "Category": selectedCategory,
      if (AlgorithmInput.contains(selectedAlgorithm!, "Date Set"))
        "Date Set": deadlineController.text,
      if (AlgorithmInput.contains(selectedAlgorithm!, "Priority Change"))
        "Priority Change": priorityChangeController.text,
      if (AlgorithmInput.contains(selectedAlgorithm!, "Premption Rule"))
        "Preemption Rule": preemptionRuleController.text,
    };

    setState(() {
      tasks.add(task);
      if (!isStartTimeSet) {
        isStartTimeSet = true; // start time has been set
      }
    });

    //print("Task Added: $task"); 
  }

  void clearFields() {
    setState(() {
      nameController.clear();
      durationController.clear();
      priorityController.clear();
      preemptionRuleController.clear();
      deadlineController.clear();
      startTimeController.clear();
    });
  }

  void showTaskDetails(BuildContext context, List<Map<String, dynamic>> tasks) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Task Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tasks.asMap().entries.map((entry) {
              final int index = entry.key + 1; // Task Index
              final Map<String, dynamic> task = entry.value;
              final taskName = task["Assignment Name"] ?? "Unnamed Task";
              final duration = task["Duration"]?.toString() ?? "Unknown";
              final priority = task["Priority"]?.toString() ?? "Unknown";
              final category = task["Category"] ?? "Unknown";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Task $index:\n"
                  "Name: $taskName\n"
                  "Duration: $duration hours\n"
                  "Priority: $priority\n"
                  "Category: $category\n",
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

  @override
  Widget build(BuildContext context) {
    final requiredInputs =
        AlgorithmInput.algorithmInputs[selectedAlgorithm] ?? [];

    return Scaffold(
      body: Row(
        children: [
          // Left side with logo
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFFCFC6BA), 
              child: Center(
                child: Image.asset(
                  'assets/images/logo_top.png',
                  fit: BoxFit.contain,
                  width: 250,
                ),
              ),
            ),
          ),
          // Right side with inputs and back arrow
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Text(
                          "Please fill in the required details:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 239, 4, 4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // input fields
                        ...requiredInputs.map((inputType) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFF0ECE3), 
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _buildInputField(inputType),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                        // Add Task Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 175, 169, 152),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            saveTask();
                            clearFields();
                          },
                          child: const Text(
                            'ADD TASK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Submit Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 175, 169, 152),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            //print("Final Tasks: $tasks"); // Debugging

                            final String startTimeText =
                                startTimeController.text;
                            final DateTime? startDateTime =
                                DateTime.tryParse(startTimeText);

                            // mins from 0000
                            final int startTimeInMinutes = startDateTime != null
                                ? startDateTime.hour * 60 + startDateTime.minute: 720;

                            // quantum time from studyTimeController
                            final double quantumTime =
                                double.tryParse(studyTimeController.text) ??
                                    0.5; // default 

                            final String preemptionRule =
                                preemptionRuleController.text.isNotEmpty
                                    ? preemptionRuleController.text
                                    : "Shorter Tasks";

                            final Scheduler scheduler = Scheduler.create(
                                quantumTime,
                                startTimeInMinutes,
                                slots,
                                preemptionRule);

                            // scheduling result
                            List<ScheduledProcess> schedulingResult = scheduler
                                .executeAlgorithm(selectedAlgorithm!, tasks);

                            // task names
                            final Map<int, String> taskNames = {
                              for (var task in tasks)
                                task["pid"]: task["Assignment Name"] ??
                                    "Task ${task["pid"]}"
                            };

                            

                            // Navigation
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GanttChartFramework(
                                  schedulingResult: schedulingResult,
                                  taskNames: taskNames,
                                  algorithmName:
                                      selectedAlgorithm!, 
                                  startTime: startTimeInMinutes,
                                  quantumTime: quantumTime,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      // Task Details Button
                        ElevatedButton(
                          onPressed: () => showTaskDetails(context, tasks),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text("Show Task Details", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Back arrow
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuantumTimeFramework(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String inputType) {
    //print("Building input field for $inputType"); 

    // Reusable decoration for all fields
    InputDecoration buildInputDecoration(String labelText,
        {Widget? suffixIcon}) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black54),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF0ECE3), // Beige color
        suffixIcon: suffixIcon,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECE3), // Beige background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          if (inputType == "Start Time") {
            if (!isStartTimeSet) {
              return TextField(
                controller: startTimeController,
                readOnly: true, // Use date and time picker
                onTap: () async {
                  // Open time picker
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      // Format the time to "HH:mm" before assigning it to startTimeController
                      startTimeController.text =
                          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                      isStartTimeSet = true; // Flag to ensure Start Time is set
                      //print("Start Time Selected: ${startTimeController.text}"); 
                    });
                  } else {
                    print("No Start Time selected!"); // fallback
                  }
                },
                decoration: buildInputDecoration(
                    "Start Time"), // Use consistent styling
              );
            } else {
              // Return an empty widget if Start Time is already set
              return const SizedBox.shrink();
            }
          }

          // Default switch case behavior
          switch (inputType) {
            case "Assignment Name":
              return TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.black),
                decoration: buildInputDecoration("Task Name"),
              );

            case "Study Time":
              return TextField(
                controller: studyTimeController,
                style: const TextStyle(color: Colors.black),
                decoration: buildInputDecoration("Study Time (hours)"),
                readOnly: true, // Prevent manual edits if study time is fixed
              );

            case "Duration":
              return TextField(
                controller: durationController,
                style: const TextStyle(color: Colors.black),
                decoration: buildInputDecoration("Duration (hours)"),
              );

            case "Priority":
              return DropdownButtonFormField<String>(
                value: priorityController.text.isNotEmpty
                    ? priorityController.text
                    : null,
                onChanged: (value) {
                  setState(() {
                    priorityController.text = value ?? "";
                    // print("Priority Selected: ${priorityController.text}");
                  });
                },
                items: const [
                  DropdownMenuItem(value: "1", child: Text("Low")),
                  DropdownMenuItem(value: "2", child: Text("Medium")),
                  DropdownMenuItem(value: "3", child: Text("High")),
                ],
                decoration: buildInputDecoration("Priority"),
              );

            case "Preemption Rule":
            case "Priority Change":
              return DropdownButtonFormField<String>(
                value: preemptionRuleController.text.isEmpty
                    ? null
                    : preemptionRuleController.text,
                onChanged: (value) {
                  setState(() {
                    preemptionRuleController.text = value ?? "";
                  });
                },
                items: const [
                  DropdownMenuItem(
                      value: "Higher priority Tasks",
                      child: Text("Higher priority Tasks")),
                  DropdownMenuItem(
                      value: "Shorter Tasks", child: Text("Shorter Tasks")),
                  DropdownMenuItem(
                      value: "Lower Effort Tasks",
                      child: Text("Lower Effort Tasks")),
                  DropdownMenuItem(
                      value: "Takss with imminent deadlines",
                      child: Text("Tasks with imminent deadlines")),
                ],
                decoration: buildInputDecoration("Preemption Rule"),
              );

            case "Category":
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory, 
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value ?? "";
                        // print("Selected Category: $selectedCategory");
                      });
                    },
                    items: slots
                        .where((slot) => slot != null) // remove empty slots
                        .map((slot) {
                      return DropdownMenuItem(
                        value: slot,
                        child: Text(slot!), 
                      );
                    }).toList(),
                    decoration: buildInputDecoration("Category"),
                  ),
                  const SizedBox(height: 12),

                  // Read-only Category 
                  TextFormField(
                    controller: TextEditingController(
                      text: slots.indexOf(selectedCategory) != -1
                          ? (slots.indexOf(selectedCategory) + 1).toString()
                          : "",
                    ),
                    style: const TextStyle(color: Colors.black),
                    decoration:
                        buildInputDecoration("Effort (Derived from Category)"),
                    readOnly: true, 
                  ),
                ],
              );

            case "Date Set":
            case "Deadline":
              return TextField(
                controller: deadlineController,
                style: const TextStyle(color: Colors.black),
                decoration: buildInputDecoration(
                  "Deadline (Date & Time)",
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true, // no manual editing
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      final selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      setState(() {
                        deadlineController.text = selectedDateTime.toString();
                      });

                      //print("Selected DateTime: $selectedDateTime"); 
                    }
                  }
                },
              );

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
