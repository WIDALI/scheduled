import 'dart:collection';

class ScheduledProcess {
  final int pid;
  final int startTime;
  final int endTime;

  ScheduledProcess({
    required this.pid,
    required this.startTime,
    required this.endTime,
  });
}


class Process {
  final int pid;
  final int burstTime;
  final int priority;
  final DateTime deadline;

  Process({
    required this.pid,
    required this.burstTime,
    required this.priority,
    required this.deadline,
  });
}

class Scheduler {
  final double quantumTime;
  final int startTime;
  final List<String?> slots;
  final String preemptionRule;

  Scheduler({required this.quantumTime, required this.startTime, required this.slots, required this.preemptionRule,});

  // map to store registered algorithms
  final Map<String, Function> algorithms = {};



  // Initialize and register algorithms
  Scheduler._initialize({required this.quantumTime, required this.startTime, required this.slots, required this.preemptionRule,}) {
    algorithms['Dynamic Priority MLQ'] = (List<Map<String, dynamic>> tasks) => dynamicPriorityMLQ(tasks, startTime, slots);
    algorithms['Static Priority MLQ'] = (List<Map<String, dynamic>> tasks) => staticPriorityMLQ(tasks, startTime, slots);
    algorithms['Strict Time-Slice RR'] = (List<Map<String, dynamic>> tasks) => strictTimeSliceRoundRobin(tasks, quantumTime, startTime);
    algorithms['No Workflow'] = (List<Map<String, dynamic>> tasks) => noWorkflow(tasks, startTime);
    algorithms['Dynamic RR'] = (List<Map<String, dynamic>> tasks) => dynamicRoundRobin(tasks, quantumTime, startTime, slots);
    algorithms['Dynamic Weighted FCFS'] = (List<Map<String, dynamic>> tasks) => dynamicWeightedFCFS(tasks, startTime, slots);
    algorithms['Static FCFS'] = (List<Map<String, dynamic>> tasks) => staticFCFS(tasks, startTime);
    algorithms['Dynamic Weighted SJF'] = (List<Map<String, dynamic>> tasks) => dynamicWeightedSJF(tasks, startTime, slots);
    algorithms['FCFS with Priority Overrides'] = (List<Map<String, dynamic>> tasks) => fcfsWithPriorityOverrides(tasks, startTime);
    algorithms['Preemptive SJF'] = (List<Map<String, dynamic>> tasks) => preemptiveSJF(tasks, startTime, preemptionRule);
    algorithms['Dynamic MLQ'] = (List<Map<String, dynamic>> tasks) => dynamicMLQ(tasks, startTime);
    // algorithms['Round Robin'] = (List<Map<String, dynamic>> tasks) => roundRobin(tasks, startTime, quantumTime);
    algorithms['Dynamic Priority'] = (List<Map<String, dynamic>> tasks) => dynamicPriority(tasks, startTime, preemptionRule);
    algorithms['Static Priority'] = (List<Map<String, dynamic>> tasks) => staticPriority(tasks, startTime);
    algorithms['MLQ with reprioritisation'] = (List<Map<String, dynamic>> tasks) => mlqWithReprioritisation(tasks, startTime, preemptionRule);
    algorithms['Static Priority with FCFS'] = (List<Map<String, dynamic>> tasks) => staticPriorityWithFCFS(tasks, startTime);
    algorithms['Static Priority with SJF'] = (List<Map<String, dynamic>> tasks) => staticPriorityWithSJF(tasks, startTime);
    algorithms['Hybrid Priority MLQ'] = (List<Map<String, dynamic>> tasks) => hybridPriorityMLQ(tasks, startTime, preemptionRule);
    algorithms['Pre-assigned Fixed RR'] = (List<Map<String, dynamic>> tasks) => preAssignedFixedRR(tasks, startTime, quantumTime);
    algorithms['General Fixed RR'] = (List<Map<String, dynamic>> tasks) => generalFixedRR(tasks, startTime, quantumTime);
    algorithms['Deadline Adaptive RR'] = (List<Map<String, dynamic>> tasks) => deadlineAdaptiveRR(tasks, startTime, quantumTime);
    algorithms['Size Adaptive RR'] = (List<Map<String, dynamic>> tasks) => sizeAdaptiveRR(tasks, startTime, quantumTime, slots);
    algorithms['Static Weighted SJF'] = (List<Map<String, dynamic>> tasks) => staticWeightedSJF(tasks, startTime, slots); 
    algorithms['Static Weighted MLQ'] = (List<Map<String, dynamic>> tasks) => staticWeightedMLQ(tasks, startTime, slots);
  }

  // ensures all necessary inputs are passed
  factory Scheduler.create(double quantumTime, int startTime, List<String?> slots, String preemptionRule) {
    return Scheduler._initialize(
        quantumTime: quantumTime, startTime: startTime, slots: slots, preemptionRule: preemptionRule);
  }

  // algorithm execution
  List<ScheduledProcess> executeAlgorithm(
      String algorithmName, List<Map<String, dynamic>> tasks) {
    if (!algorithms.containsKey(algorithmName)) {
      throw ArgumentError('Algorithm $algorithmName not implemented.');
    }
    return algorithms[algorithmName]!(tasks);
  }
}

//ALGORITHMS


List<ScheduledProcess> dynamicPriorityMLQ(
    List<Map<String, dynamic>> tasks, int startTime, List<String?> slots) {
  int currentTime = startTime; 

  // categories to priorities (or weights)
  Map<String?, int> categoryToPriority = {};
  for (int i = 0; i < slots.length; i++) {
    categoryToPriority[slots[i]] = i + 1; // higher priority = smaller number
  }

  // Sort tasks by (category-based) priority and deadline 
  tasks.sort((a, b) {
    int priorityA = a["Priority"] ?? categoryToPriority[a["Category"]] ?? (slots.length + 1);
    int priorityB = b["Priority"] ?? categoryToPriority[b["Category"]] ?? (slots.length + 1);

    if (priorityA == priorityB) {
      final deadlineA = a["Deadline"] is DateTime ? a["Deadline"] : DateTime.tryParse(a["Deadline"] ?? '');
      final deadlineB = b["Deadline"] is DateTime ? b["Deadline"] : DateTime.tryParse(b["Deadline"] ?? '');

      if (deadlineA != null && deadlineB != null) {
        return deadlineA.compareTo(deadlineB); // earlier deadline first
      }
      return 0; // if are invalid or equal
    }
    return priorityB.compareTo(priorityA); // high priority first
  });

  List<ScheduledProcess> schedule = [];

  // schedule tasks in the sorted order
  for (var task in tasks) {
    if (!task.containsKey("Duration") || task["Duration"] == null) {
      //print("Skipping task with invalid duration: $task");
      continue;
    }

    // hours -> mins
    final int durationInMinutes = (task["Duration"] as double).toInt() * 60;

    int taskStartTime = currentTime;
    int taskEndTime = taskStartTime + durationInMinutes;

    schedule.add(ScheduledProcess(
      pid: task["pid"],
      startTime: taskStartTime,
      endTime: taskEndTime,
    ));

    currentTime = taskEndTime; // time update
  }

  return schedule;
}


List<ScheduledProcess> staticPriorityMLQ(
    List<Map<String, dynamic>> tasks, int startTime, List<String?> slots) {
  
  //respective priorities
  Map<String?, int> categoryToPriority = {};
  for (int i = 0; i < slots.length; i++) {
    categoryToPriority[slots[i]] = i + 1; // Higher priority = smaller number
  }

  // group tasks by priority
  Map<int, List<Map<String, dynamic>>> priorityQueues = {};
  for (var task in tasks) {
    String? category = task["Category"];
    int priority = categoryToPriority[category] ?? slots.length + 1;

    if (!priorityQueues.containsKey(priority)) {
      priorityQueues[priority] = [];
    }
    priorityQueues[priority]!.add(task);
  }

  // sort tasks within each priority queue by duration (SJF)
  priorityQueues.forEach((priority, taskList) {
    taskList.sort((a, b) {
      final durationA = ((a["Duration"] as num?)?.toDouble() ?? 0.0) * 60; 
      final durationB = ((b["Duration"] as num?)?.toDouble() ?? 0.0) * 60;
      return durationA.compareTo(durationB);
    });
  });

  // priority order
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  //priority levels (low to high)
  List<int> priorityOrder = priorityQueues.keys.toList()..sort();

  for (int priority in priorityOrder) {
    for (var task in priorityQueues[priority]!) {
      if (!task.containsKey("Duration") || task["Duration"] == null) {
       // print("Skipping task with invalid duration: $task");
        continue;
      }

      // duration to minutes
      final int durationInMinutes = ((task["Duration"] as num?)?.toDouble() ?? 0.0).toInt() * 60;
      int taskStartTime = currentTime;
      int taskEndTime = taskStartTime + durationInMinutes;

      schedule.add(ScheduledProcess(
        pid: task["pid"] ?? -1, // default
        startTime: taskStartTime,
        endTime: taskEndTime,
      ));

      currentTime = taskEndTime; // update currentTime for the next task
    }
  }

  return schedule;
}


List<ScheduledProcess> strictTimeSliceRoundRobin(
    List<Map<String, dynamic>> tasks, double quantumTime, int startTime) {
  
  List<ScheduledProcess> schedule = [];

  // queue to store tasks for round-robin scheduling
  Queue<Map<String, dynamic>> taskQueue = Queue.from(tasks);

  // start scheduling here
  int currentTime = startTime;

  while (taskQueue.isNotEmpty) {
    var task = taskQueue.removeFirst();  // dequeue the first task

    //validation
    if (task["Duration"] == null || (task["Duration"] as num) <= 0) {
      //print("Skipping invalid task: $task");
      continue;
    }

    // hours -> mins
    final double originalDuration = (task["Duration"] as num).toDouble() * 60;
    final double remainingTime = task.containsKey("Remaining Duration")
        ? (task["Remaining Duration"] as num).toDouble()
        : originalDuration;

    // calculate new quantumTime
    final double timeSlice =
        remainingTime <= quantumTime * 60 ? remainingTime : quantumTime * 60;

    // start and end times
    int startTimeForTask = currentTime;
    int endTimeForTask = startTimeForTask + timeSlice.toInt();

    // add the scheduled task to the result
    schedule.add(ScheduledProcess(
      pid: task["pid"],
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    // Update the current time
    currentTime = endTimeForTask;

    // update its remaining duration and re-add it to the queue
    if (remainingTime > timeSlice) {
      task["Remaining Duration"] = remainingTime - timeSlice;
      taskQueue.add(task);
    }
  }

  return schedule;
}


List<ScheduledProcess> noWorkflow(
    List<Map<String, dynamic>> tasks, int startTime) {
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  for (var task in tasks) {
    // validation
    if (task["Duration"] == null || (task["Duration"] as num) <= 0) {
      //print("Skipping task with invalid duration: $task");
      continue; // Skip invalid tasks
    }

    int pid = task["pid"];
    double duration = task["Duration"] as double;

    // Convert duration from hours to minutes
    int durationInMinutes = (duration * 60).toInt();
    //print("Task PID: $pid, Duration (hours): $duration, Duration (minutes): $durationInMinutes"); // Debugging

    // Calculate start and end times
    int startTimeForTask = currentTime;
    int endTimeForTask = startTimeForTask + durationInMinutes;

    // Add the task to the schedule
    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));
    //print("Scheduled Task - PID: $pid, Start Time: $startTimeForTask, End Time: $endTimeForTask"); // Debugging

    // Update the current time
    currentTime = endTimeForTask;
  }

  return schedule;
}


List<ScheduledProcess> dynamicRoundRobin(
    List<Map<String, dynamic>> tasks, double quantumTime, int startTime, List<String?> slots) {
  List<ScheduledProcess> schedule = [];
  Queue<Map<String, dynamic>> queue = Queue.from(tasks);

  int currentTime = startTime;

  // respective weights based on the slots
  Map<String?, double> categoryWeights = {};
  for (int i = 0; i < slots.length; i++) {
    categoryWeights[slots[i]] = 1.0 + (i * 0.5); // higher slot = higher weight
  }

  while (queue.isNotEmpty) {
    var task = queue.removeFirst();

    int pid = task["pid"];

    // duration (mins)
    if (task["Duration"] == null || (task["Duration"] as num) <= 0) {
      //print("Skipping task with invalid duration: $task");
      continue; // skips
    }

    double remainingDuration =
        ((task["Duration"] as double) * 60) - (task["Completed"] ?? 0.0); 

    //print("Task PID: $pid, Remaining Duration (minutes): $remainingDuration"); 

    // gets the category weight or use default value
    String? category = task["Category"];
    double categoryWeight = categoryWeights[category] ?? 1.0;

    // quantum based on category weight
    double adjustedQuantum = quantumTime * 60 * categoryWeight; 
    //print("Task PID: $pid, Category: $category, Category Weight: $categoryWeight, Adjusted Quantum: $adjustedQuantum"); 

    if (remainingDuration <= adjustedQuantum) {
      int startTimeForTask = currentTime;
      int endTimeForTask = currentTime + remainingDuration.toInt(); //needed to convert lol

      schedule.add(ScheduledProcess(
        pid: pid,
        startTime: startTimeForTask,
        endTime: endTimeForTask,
      ));

      currentTime = endTimeForTask;
    } else {
      // Task partially completes
      int startTimeForTask = currentTime;
      int endTimeForTask = currentTime + adjustedQuantum.toInt();

      schedule.add(ScheduledProcess(
        pid: pid,
        startTime: startTimeForTask,
        endTime: endTimeForTask,
      ));

      // update remaining duration and enqueue
      task["Completed"] = (task["Completed"] ?? 0.0) + adjustedQuantum;
      queue.add(task);

      currentTime = endTimeForTask;
    }
  }

  return schedule;
}


List<ScheduledProcess> dynamicWeightedFCFS(
    List<Map<String, dynamic>> tasks, int startTime, List<String?> slots) {
  // weights respective to slots
  Map<String?, double> categoryWeights = {};
  for (int i = 0; i < slots.length; i++) {
    categoryWeights[slots[i]] = (i + 1).toDouble(); // higher slot index = higher weight
  }

  // assign category weight to each task
  for (var task in tasks) {
    String? category = task["Category"];
    task["Category Weight"] = categoryWeights[category] ?? 1.0; // default
  }

  // in descending order
  tasks.sort((a, b) {
    final double weightA = a["Category Weight"] ?? 1.0;
    final double weightB = b["Category Weight"] ?? 1.0;
    return weightB.compareTo(weightA); // higher weight tasks come first
  });

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  for (var task in tasks) {
    if (task["Duration"] == null || (task["Duration"] as num) <= 0) {
      //print("Skipping task with invalid duration: $task");
      continue; // skip invalid
    }

    final int pid = task["pid"];
    final double durationInHours = task["Duration"] as double? ?? 0.0; 
    final double weight = task["Category Weight"] ?? 1.0;

    // duration (weight-based)
    final int durationInMinutes = (durationInHours * 60).toInt();
    final int adjustedDuration = (durationInMinutes / weight).ceil(); //round

  
    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + adjustedDuration;

    // debugs
    // print("Task ID: $pid");
    // print("Original Duration (minutes): $durationInMinutes");
    // print("Adjusted Duration (minutes): $adjustedDuration");
    // print("Start Time: $startTimeForTask, End Time: $endTimeForTask");

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    currentTime = endTimeForTask; 
  }

  return schedule;
}



List<ScheduledProcess> staticFCFS(
    List<Map<String, dynamic>> tasks, int startTime) {
  // FIFO
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  for (var task in tasks) {
    if (task["Duration"] == null || (task["Duration"] as num) <= 0) {
      //print("Skipping task with invalid duration: $task");
      continue; // invalid 
    }

    final int pid = task["pid"] ?? -1; // default 
    final double durationInHours = task["Duration"] as double; 

    // duration -> minutes
    final int durationInMinutes = (durationInHours * 60).toInt();

    
    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + durationInMinutes;

    // debugs
    /* print("Task ID: $pid");
    print("Duration (minutes): $durationInMinutes");
    print("Start Time: $startTimeForTask");
    print("End Time: $endTimeForTask"); */

    
    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    
    currentTime = endTimeForTask;
  }

  return schedule;
}



List<ScheduledProcess> dynamicWeightedSJF(
    List<Map<String, dynamic>> tasks, int startTime, List<String?> slots) {
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  while (tasks.isNotEmpty) {
    // adjusted durations and sort tasks
    tasks.sort((a, b) {
      // weights for categories
      final double weightA = (slots.indexOf(a["Category"]) != -1)
          ? (slots.indexOf(a["Category"]) + 1).toDouble()
          : 1.0; // default
      final double weightB = (slots.indexOf(b["Category"]) != -1)
          ? (slots.indexOf(b["Category"]) + 1).toDouble()
          : 1.0;

      // duration -> minutes
      final double adjustedDurationA = (((a["Duration"] as double?) ?? 0.0) * 60) / weightA;
      final double adjustedDurationB = (((b["Duration"] as double?) ?? 0.0) * 60) / weightB;

      return adjustedDurationA.compareTo(adjustedDurationB);
    });

    // task w/ shortest adjusted duration
    final task = tasks.removeAt(0);

    final int pid = task["pid"] ?? -1; 
    final double durationInHours = task["Duration"] as double? ?? 0.0;
    final double weight = (slots.indexOf(task["Category"]) != -1)
        ? (slots.indexOf(task["Category"]) + 1).toDouble()
        : 1.0;


    final int durationInMinutes = (durationInHours * 60).toInt();
    final double adjustedDuration = durationInMinutes / weight;

    if (adjustedDuration <= 0) {
      //print("Skipping task with invalid duration: $task");
      continue;
    }

    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + adjustedDuration.ceil();

    // Debugging
    /* print("Task PID: $pid");
    print("Original Duration (minutes): $durationInMinutes");
    print("Weight: $weight");
    print("Adjusted Duration: $adjustedDuration");
    print("Start Time: $startTimeForTask");
    print("End Time: $endTimeForTask"); */

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    currentTime = endTimeForTask; 
  }

  return schedule;
}



List<ScheduledProcess> fcfsWithPriorityOverrides(
    List<Map<String, dynamic>> tasks, int startTime) {
  // sort tasks by start time (if different), then by descending priority, then deadline
  tasks.sort((a, b) {
    final int startTimeA = a["Start Time"] ?? startTime;
    final int startTimeB = b["Start Time"] ?? startTime;

    if (startTimeA == startTimeB) {
      final int priorityA = a["Priority"] ?? 0;
      final int priorityB = b["Priority"] ?? 0;

      if (priorityA == priorityB) {
        final DateTime? deadlineA = a["Deadline"];
        final DateTime? deadlineB = b["Deadline"];
        if (deadlineA != null && deadlineB != null) {
          return deadlineA.compareTo(deadlineB); // earliest deadline first
        }
        return 0; // no further sorting 
      }

      return priorityB.compareTo(priorityA); // higher priority first
    }

    return startTimeA.compareTo(startTimeB); // earlier start time first
  });

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  for (var task in tasks) {
    final int pid = task["pid"] ?? -1;
    final int taskStartTime = task["Start Time"] ?? currentTime;

    // duration -> mins
    final double durationInHours = (task["Duration"] as double?) ?? 0.0;
    final int durationInMinutes = (durationInHours * 60).toInt();

    // if task arrives after current time move time forward
    if (taskStartTime > currentTime) {
      currentTime = taskStartTime;
    }

    // skip invalid durations
    if (durationInMinutes <= 0) {
      //print("Skipping task with invalid duration: $task");
      continue;
    }

    int startTimeForTask = currentTime;
    int endTimeForTask = startTimeForTask + durationInMinutes;

    // debug
    /* print("Task PID: $pid");
    print("Start Time: $startTimeForTask");
    print("End Time: $endTimeForTask");
    print("Duration (minutes): $durationInMinutes"); */

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    
    currentTime = endTimeForTask;
  }

  return schedule;
}



List<ScheduledProcess> preemptiveSJF(
    List<Map<String, dynamic>> tasks, int startTime, String preemptionRule) {
  // sort tasks by start time 
  tasks.sort((a, b) => a["Start Time"].compareTo(b["Start Time"]));

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime; 
  List<Map<String, dynamic>> taskQueue = [];

  // duration -> minutes
  for (var task in tasks) {
    if (!task.containsKey("Duration") || task["Duration"] == null) {
      //print("Skipping task with invalid duration: $task");
      continue;
    }
    task["Remaining Duration"] = ((task["Duration"] as double) * 60).toInt(); // Convert hours to minutes
  }

  int i = 0;
  Map<String, dynamic>? runningTask;

  while (i < tasks.length || taskQueue.isNotEmpty || runningTask != null) {
    // enquue new
    while (i < tasks.length && tasks[i]["Start Time"] <= currentTime) {
      taskQueue.add(tasks[i]);
      i++;
    }

    // sort by preemption rule
    if (preemptionRule == "Shorter Tasks") {
      taskQueue.sort((a, b) =>
          (a["Remaining Duration"] as num).compareTo(b["Remaining Duration"]));
    } else if (preemptionRule == "Higher priority Tasks") {
      taskQueue.sort((a, b) =>
          (b["Priority"] as num).compareTo(a["Priority"] as num)); // higher priority first
    } else if (preemptionRule == "Lower Effort Tasks") {
      taskQueue.sort((a, b) =>
          (a["Effort"] as num).compareTo(b["Effort"] as num)); // lower effort first
    } else if (preemptionRule == "Tasks with imminent deadlines") {
      taskQueue.sort((a, b) =>
          (a["Deadline"] as DateTime).compareTo(b["Deadline"] as DateTime)); // earliest deadline first
    }

    // check for preemption rules
    if (runningTask != null &&
        taskQueue.isNotEmpty &&
        ((preemptionRule == "Shorter Tasks" &&
                taskQueue.first["Remaining Duration"] <
                    runningTask["Remaining Duration"]) ||
            (preemptionRule == "Higher priority Tasks" &&
                taskQueue.first["Priority"] > runningTask["Priority"]) ||
            (preemptionRule == "Lower Effort Tasks" &&
                taskQueue.first["Effort"] < runningTask["Effort"]) ||
            (preemptionRule == "Tasks with imminent deadlines" &&
                taskQueue.first["Deadline"].isBefore(runningTask["Deadline"])))) {
      // pause current task and enqueue
      taskQueue.add(runningTask);
      runningTask = null;
    }

    // run next
    if (runningTask == null && taskQueue.isNotEmpty) {
      runningTask = taskQueue.removeAt(0);
      schedule.add(ScheduledProcess(
        pid: runningTask["pid"],
        startTime: currentTime,
        endTime: currentTime +
            (runningTask["Remaining Duration"] as num).toInt(), 
      ));
    }

    if (runningTask != null) {
      
      runningTask["Remaining Duration"] =
          ((runningTask["Remaining Duration"] as num) - 1).toInt();
      currentTime++;

      // remove task
      if ((runningTask["Remaining Duration"] as num).toInt() == 0) {
        runningTask = null;
      }
    } else {
      currentTime++;
    }
  }

  return schedule;
}


List<ScheduledProcess> dynamicMLQ(
    List<Map<String, dynamic>> tasks, int startTime) {
  // three priority levels
  List<Map<String, dynamic>> highPriorityQueue = [];
  List<Map<String, dynamic>> mediumPriorityQueue = [];
  List<Map<String, dynamic>> lowPriorityQueue = [];

  // different priority queues
  for (var task in tasks) {
    final int priority = task["Priority"] ?? 1; 

    if (priority == 3) {
      highPriorityQueue.add(task);
    } else if (priority == 2) {
      mediumPriorityQueue.add(task);
    } else if (priority == 1) {
      lowPriorityQueue.add(task);
    } else {
      throw ArgumentError("Invalid Priority: $priority");
    }
  }

  // tasks by deadlines
  highPriorityQueue.sort((a, b) => a["Deadline"].compareTo(b["Deadline"]));
  mediumPriorityQueue.sort((a, b) => a["Deadline"].compareTo(b["Deadline"]));
  lowPriorityQueue.sort((a, b) => a["Deadline"].compareTo(b["Deadline"]));

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // high to low priority
  List<List<Map<String, dynamic>>> priorityQueues = [
    highPriorityQueue,
    mediumPriorityQueue,
    lowPriorityQueue,
  ];

  for (var queue in priorityQueues) {
    for (var task in queue) {
      // validation
      if (!task.containsKey("Duration") || task["Duration"] == null) {
        //print("Skipping task with invalid duration: $task");
        continue;
      }

      if (!task.containsKey("pid") || task["pid"] == null) {
        //print("Skipping task with missing pid: $task");
        continue;
      }

      // conversion
      final int durationInMinutes = ((task["Duration"] as double?) ?? 0.0 * 60).toInt();

      //skip invalid tasks
      if (durationInMinutes <= 0) {
        //print("Skipping task with invalid converted duration: $task");
        continue;
      }

      int taskStartTime = currentTime;
      int taskEndTime = currentTime + durationInMinutes;

      // Debugging
      /* print("Task PID: ${task["pid"]}");
      print("Priority: ${task["Priority"]}");
      print("Start Time: $taskStartTime, End Time: $taskEndTime, Duration (minutes): $durationInMinutes"); */

      schedule.add(ScheduledProcess(
        pid: task["pid"],
        startTime: taskStartTime,
        endTime: taskEndTime,
      ));

      currentTime = taskEndTime; 
    }
  }

  return schedule;
}


List<ScheduledProcess> dynamicPriority(
    List<Map<String, dynamic>> tasks, int startTime, String preemptionRule) {
  // sort by arrival time
  tasks.sort((a, b) => a["Start Time"].compareTo(b["Start Time"]));

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;
  List<Map<String, dynamic>> taskQueue = [];

  // durations -> mins 
  for (var task in tasks) {
    if (task["Duration"] == null) {
      //print("Skipping task with invalid duration: $task");
      continue;
    }

    
    final double durationInMinutes = (task["Duration"] as double) * 60;

    // esnures remaining duration is set
    task["Remaining Duration"] = task["Remaining Duration"] ?? durationInMinutes;

  
  }

  int i = 0;
  Map<String, dynamic>? runningTask;

  while (i < tasks.length || taskQueue.isNotEmpty || runningTask != null) {
    // enqueue
    while (i < tasks.length && tasks[i]["Start Time"] <= currentTime) {
      taskQueue.add(tasks[i]);
      i++;
    }

    // apply preemption rule to sort task queue
    if (taskQueue.isNotEmpty) {
      taskQueue.sort((a, b) {
        if (preemptionRule == "Higher priority Tasks") {
          return b["Priority"].compareTo(a["Priority"]); // higher priority first
        } else if (preemptionRule == "Shorter Tasks") {
          return (a["Remaining Duration"] as num)
              .compareTo(b["Remaining Duration"] as num); // shorter tasks first
        } else if (preemptionRule == "Lower Effort Tasks") {
          return (a["Effort"] ?? 1).compareTo(b["Effort"] ?? 1); // lower effort first
        } else if (preemptionRule == "Tasks with imminent deadlines") {
          return a["Deadline"].compareTo(b["Deadline"]); // earlier deadlines first
        }
        return 0; // fallback
      });
    }

    // for preemption
    if (runningTask != null &&
        taskQueue.isNotEmpty &&
        taskQueue.first["Priority"] > runningTask["Priority"]) {
      // pause running enqueue at tail
      taskQueue.add(runningTask);
      runningTask = null;
    }

    // select next task 
    if (runningTask == null && taskQueue.isNotEmpty) {
      runningTask = taskQueue.removeAt(0);

      // end time based on remaining duration
      final double remainingDuration =
          (runningTask["Remaining Duration"] as num).toDouble();
      int taskEndTime = currentTime + remainingDuration.toInt();

      schedule.add(ScheduledProcess(
        pid: runningTask["pid"] as int,
        startTime: currentTime,
        endTime: taskEndTime,
      ));
    }

    // current task
    if (runningTask != null) {
      runningTask["Remaining Duration"] =
          (runningTask["Remaining Duration"] as num) - 1;
      currentTime++;

      // remove if finished
      if ((runningTask["Remaining Duration"] as num) <= 0) {
        runningTask = null;
      }
    } else {
      currentTime++;
    }
  }

  return schedule;
}


List<ScheduledProcess> staticPriority(
    List<Map<String, dynamic>> tasks, int startTime) {

  //  descending priority 
  tasks.sort((a, b) => (b["Priority"] as int).compareTo(a["Priority"] as int));

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  for (var task in tasks) {
    // validation
    if (task["Duration"] == null) {
      //print("Skipping task with invalid duration: $task");
      continue;
    }

    final int pid = task["pid"];

    // duration -> minutes
    final int durationInMinutes = ((task["Duration"] as num).toDouble() * 60).toInt();

    // debug
    // print("Task ID: $pid, Duration (minutes): $durationInMinutes");

    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + durationInMinutes;

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    currentTime = endTimeForTask; 
  }

  return schedule;
}


List<ScheduledProcess> mlqWithReprioritisation(
    List<Map<String, dynamic>> tasks, int startTime, String preemptionRule) {
  
  // queues for three priority levels
  List<Map<String, dynamic>> highPriorityQueue = [];
  List<Map<String, dynamic>> mediumPriorityQueue = [];
  List<Map<String, dynamic>> lowPriorityQueue = [];

  // tasks set in different priority queues
  for (var task in tasks) {
    final int priority = task["Priority"] ?? 1; 
    if (priority == 3) {
      highPriorityQueue.add(task);
    } else if (priority == 2) {
      mediumPriorityQueue.add(task);
    } else {
      lowPriorityQueue.add(task);
    }
  }

  // reprioritisation rules
  if (preemptionRule == "Higher priority Tasks") {
    // by duration
    highPriorityQueue.sort((a, b) => a["Duration"].compareTo(b["Duration"]));
    mediumPriorityQueue.sort((a, b) => a["Duration"].compareTo(b["Duration"]));
    lowPriorityQueue.sort((a, b) => a["Duration"].compareTo(b["Duration"]));
  } else if (preemptionRule == "Shorter Tasks") {
    // shorter tasks 
    final allTasks = [...highPriorityQueue, ...mediumPriorityQueue, ...lowPriorityQueue];
    allTasks.sort((a, b) => (a["Duration"] as num).compareTo(b["Duration"] as num));

    // reassign reprioritised order
    highPriorityQueue = allTasks.where((task) => task["Priority"] == 3).toList();
    mediumPriorityQueue = allTasks.where((task) => task["Priority"] == 2).toList();
    lowPriorityQueue = allTasks.where((task) => task["Priority"] == 1).toList();
  }

  // process tasks queue by queue
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  for (var queue in [highPriorityQueue, mediumPriorityQueue, lowPriorityQueue]) {
    for (var task in queue) {
      // validation
      if (task["Duration"] == null) {
        // print("Skipping task with invalid duration: $task");
        continue;
      }

      final int pid = task["pid"];
      final int durationInMinutes = ((task["Duration"] as num).toDouble() * 60).toInt();

      // Debugging
      // print("Task ID: $pid, Duration (minutes): $durationInMinutes");

      int startTimeForTask = currentTime;
      int endTimeForTask = startTimeForTask + durationInMinutes;

      schedule.add(ScheduledProcess(
        pid: pid,
        startTime: startTimeForTask,
        endTime: endTimeForTask,
      ));

      currentTime = endTimeForTask; 
    }
  }

  return schedule;
}


List<ScheduledProcess> staticPriorityWithFCFS(
    List<Map<String, dynamic>> tasks, int startTime) {
  // descending priority then ascending date
  tasks.sort((a, b) {
    int priorityA = a["Priority"] ?? 1;
    int priorityB = b["Priority"] ?? 1;

    if (priorityA == priorityB) {
      // if equal, sort by earliest date 
      return a["Date Set"].compareTo(b["Date Set"]);
    }

    // higher priority comes first
    return priorityB.compareTo(priorityA);
  });

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // sorted order
  for (var task in tasks) {
    if (task["Duration"] == null) {
      //print("Skipping task with invalid duration: $task");
      continue;
    }

    final int pid = task["pid"];
    final int durationInMinutes = ((task["Duration"] as num).toDouble() * 60).toInt();

    // Debugging
    //print("Task ID: $pid, Duration (minutes): $durationInMinutes");

    int taskStartTime = currentTime;
    int taskEndTime = taskStartTime + durationInMinutes;

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: taskStartTime,
      endTime: taskEndTime,
    ));

    currentTime = taskEndTime; 
  }

  return schedule;
}


List<ScheduledProcess> staticPriorityWithSJF(
    List<Map<String, dynamic>> tasks, int startTime) {
  // tasks by priority
  Map<int, List<Map<String, dynamic>>> priorityQueues = {};
  for (var task in tasks) {
    int priority = task["Priority"] ?? 1; // default to lowest priority
    if (!priorityQueues.containsKey(priority)) {
      priorityQueues[priority] = [];
    }
    priorityQueues[priority]!.add(task);
  }

  //sort tasks in each queue by duration via SJF
  priorityQueues.forEach((priority, taskList) {
    taskList.sort((a, b) {
      final double durationA = ((a["Duration"] as num?)?.toDouble() ?? 0.0) * 60; 
      final double durationB = ((b["Duration"] as num?)?.toDouble() ?? 0.0) * 60; 
      return durationA.compareTo(durationB); // SJF
    });
  });

  // in priority order
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // highest to lowest prio
  List<int> priorityOrder = priorityQueues.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // higher prio first

  for (int priority in priorityOrder) {
    for (var task in priorityQueues[priority]!) {
      if (task["Duration"] == null) {
        //print("Skipping task with invalid duration: $task");
        continue; 
      }

      final int pid = task["pid"];
      final int durationInMinutes = ((task["Duration"] as num).toDouble() * 60).toInt();

      // Debugging
      //print("Task ID: $pid, Priority: $priority, Duration (minutes): $durationInMinutes");

      int taskStartTime = currentTime;
      int taskEndTime = taskStartTime + durationInMinutes;

      schedule.add(ScheduledProcess(
        pid: pid,
        startTime: taskStartTime,
        endTime: taskEndTime,
      ));

      currentTime = taskEndTime; 
    }
  }

  return schedule;
}


List<ScheduledProcess> hybridPriorityMLQ(
    List<Map<String, dynamic>> tasks, int startTime, String preemptionRule) {
  // priority queues for different levels
  List<Map<String, dynamic>> highPriorityQueue = [];
  List<Map<String, dynamic>> mediumPriorityQueue = [];
  List<Map<String, dynamic>> lowPriorityQueue = [];

  // tasks in priority queues
  for (var task in tasks) {
    int priority = task["Priority"] ?? 1; // default as lowest priority
    if (priority == 3) {
      highPriorityQueue.add(task);
    } else if (priority == 2) {
      mediumPriorityQueue.add(task);
    } else {
      lowPriorityQueue.add(task);
    }
  }

  // sort tasks within each priority queue based on the preemption rule
  void sortQueue(List<Map<String, dynamic>> queue) {
    if (preemptionRule == "Shorter Tasks") {
      queue.sort((a, b) =>
          ((a["Duration"] as num).toDouble() * 60).compareTo((b["Duration"] as num).toDouble() * 60));
    } else if (preemptionRule == "Higher Priority Tasks") {
      queue.sort((a, b) => b["Priority"].compareTo(a["Priority"]));
    } else if (preemptionRule == "Tasks with Imminent Deadlines") {
      queue.sort((a, b) => (a["Deadline"] ?? DateTime.now())
          .compareTo(b["Deadline"] ?? DateTime.now()));
    }
  }

  // sorting method for each queue  
  sortQueue(highPriorityQueue);
  sortQueue(mediumPriorityQueue);
  sortQueue(lowPriorityQueue);


  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // process tasks in a queue
  void processQueue(List<Map<String, dynamic>> queue) {
    for (var task in queue) {
      if (task["Duration"] == null) {
        //print("Skipping task with invalid duration: $task");
        continue; // skip invalid 
      }

      final int pid = task["pid"];
      final int durationInMinutes =
          ((task["Duration"] as num).toDouble() * 60).toInt(); 

      // Debugging
      //print("Task ID: $pid, Priority: ${task["Priority"]}, Duration (minutes): $durationInMinutes");

      int taskStartTime = currentTime;
      int taskEndTime = taskStartTime + durationInMinutes;

      schedule.add(ScheduledProcess(
        pid: pid,
        startTime: taskStartTime,
        endTime: taskEndTime,
      ));

      currentTime = taskEndTime; 
    }
  }

  // Process each priority queue
  processQueue(highPriorityQueue);
  processQueue(mediumPriorityQueue);
  processQueue(lowPriorityQueue);

  return schedule;
}


List<ScheduledProcess> preAssignedFixedRR(
    List<Map<String, dynamic>> tasks, int startTime, double quantumTime) {
  // queue for RR
  Queue<Map<String, dynamic>> taskQueue = Queue.from(tasks);

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // duration -> mins
  for (var task in tasks) {
    if (!task.containsKey("Remaining Duration")) {
      task["Remaining Duration"] =
          ((task["Duration"] as num).toDouble() * 60); 
    }
  }

  // run process
  while (taskQueue.isNotEmpty) {
    // first in queue
    var task = taskQueue.removeFirst();

    
    final int pid = task["pid"];
    final double remainingDuration = task["Remaining Duration"] as double;

    // time slice
    double executionTime = remainingDuration > quantumTime * 60
        ? quantumTime * 60
        : remainingDuration;

    
    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + executionTime.toInt();

    // Debugging
    /* print("Task ID: $pid");
    print("Remaining Duration (minutes): $remainingDuration");
    print("Execution Time (minutes): $executionTime");
    print("Start Time: $startTimeForTask, End Time: $endTimeForTask"); */

    // add task
    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

  
    currentTime = endTimeForTask;

    // if not complete update remaining duration and enqueue 
    if (remainingDuration > executionTime) {
      task["Remaining Duration"] = remainingDuration - executionTime;
      taskQueue.add(task);
    }
  }

  return schedule;
}


List<ScheduledProcess> generalFixedRR(
    List<Map<String, dynamic>> tasks, int startTime, double quantumTime) {
  //queue for RR
  Queue<Map<String, dynamic>> taskQueue = Queue.from(tasks);

  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // duration conversion
  for (var task in tasks) {
    task["Remaining Duration"] = task["Remaining Duration"] ??
        ((task["Duration"] as num).toDouble() * 60); 
  }

  // process starts
  while (taskQueue.isNotEmpty) {
    var task = taskQueue.removeFirst();

    final int pid = task["pid"];
    final double remainingDuration = task["Remaining Duration"] as double;
    final double executionTime =
        remainingDuration > quantumTime * 60 ? quantumTime * 60 : remainingDuration; 

    
    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + executionTime.toInt();

    // debugging
    /* print("Task ID: $pid");
    print("Remaining Duration (minutes): $remainingDuration");
    print("Execution Time (minutes): $executionTime");
    print("Start Time: $startTimeForTask, End Time: $endTimeForTask"); */

    // add task
    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    
    currentTime = endTimeForTask;

    // update remainder then enqueue
    if (remainingDuration > executionTime) {
      task["Remaining Duration"] = remainingDuration - executionTime;
      taskQueue.add(task);
    }
  }

  return schedule;
}


List<ScheduledProcess> deadlineAdaptiveRR(
    List<Map<String, dynamic>> tasks, int startTime, double quantumTime) {
  // sorted by deadline
  tasks.sort((a, b) => (a["Deadline"] ?? DateTime.now())
      .compareTo(b["Deadline"] ?? DateTime.now()));

  Queue<Map<String, dynamic>> taskQueue = Queue.from(tasks);
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // duration -> mins
  for (var task in tasks) {
    task["Remaining Duration"] = task["Remaining Duration"] ??
        ((task["Duration"] as num).toDouble() * 60); 
  }

  while (taskQueue.isNotEmpty) {
    // gets first task in queue
    var task = taskQueue.removeFirst();

    final int pid = task["pid"];
    final double remainingDuration = task["Remaining Duration"] as double;

    // calculate execution time
    final double executionTime = remainingDuration > quantumTime * 60 ? quantumTime * 60 : remainingDuration;

    
    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + executionTime.toInt();

    // Debugging
    /* print("Task ID: $pid");
    print("Remaining Duration (minutes): $remainingDuration");
    print("Execution Time (minutes): $executionTime");
    print("Start Time: $startTimeForTask, End Time: $endTimeForTask"); */

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    
    currentTime = endTimeForTask;

    // update remainder and enqueue
    if (remainingDuration > executionTime) {
      task["Remaining Duration"] = remainingDuration - executionTime;

      // maintain deadline ordering
      if (taskQueue.isNotEmpty) {
        List<Map<String, dynamic>> tempList = taskQueue.toList();
        tempList.add(task);

        // Sort updated queue by deadlines
        tempList.sort((a, b) => (a["Deadline"] ?? DateTime.now())
            .compareTo(b["Deadline"] ?? DateTime.now()));

        taskQueue = Queue.from(tempList);
      } else {
        taskQueue.add(task);
      }
    }
  }

  return schedule;
}


List<ScheduledProcess> sizeAdaptiveRR(
    List<Map<String, dynamic>> tasks,
    int startTime,
    double quantumTime,
    List<String?> slots) {
  
  Queue<Map<String, dynamic>> taskQueue = Queue.from(tasks);
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // quantum time adjustment based on category
  Map<String?, double> categoryWeight = {};
  for (int i = 0; i < slots.length; i++) {
    categoryWeight[slots[i]] = 1 + (i * 0.5); // increment weight by 0.5 
  }

  // conversion
  for (var task in tasks) {
    if (!task.containsKey("Remaining Duration")) {
      task["Remaining Duration"] = (task["Duration"] as double) * 60; 
    }
  }

  // RR loop
  while (taskQueue.isNotEmpty) {
    var task = taskQueue.removeFirst();

    final int pid = task["pid"];
    final double remainingDuration = task["Remaining Duration"] as double; //nremaining duration
    final String? category = task["Category"];
    final double adjustmentFactor = categoryWeight[category] ?? 1.0;

    // adjust quantum time for category weight 
    final double adjustedQuantum = quantumTime * 60 * adjustmentFactor;

    // execution time 
    final double executionTime = remainingDuration > adjustedQuantum
        ? adjustedQuantum
        : remainingDuration;

    
    final int startTimeForTask = currentTime;
    final int endTimeForTask = currentTime + executionTime.ceil();

    // Debugging
    /* print("Task ID: $pid");
    print("Category: $category");
    print("Remaining Duration (minutes): $remainingDuration");
    print("Adjusted Quantum (minutes): $adjustedQuantum");
    print("Execution Time (minutes): $executionTime");
    print("Start Time: $startTimeForTask, End Time: $endTimeForTask"); */

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    
    currentTime = endTimeForTask;

    //update remaining
    if (remainingDuration > adjustedQuantum) {
      task["Remaining Duration"] = remainingDuration - adjustedQuantum;
      taskQueue.add(task); // enqueue at tail
    }
  }

  return schedule;
}

List<ScheduledProcess> staticWeightedSJF(
    List<Map<String, dynamic>> tasks, int startTime, List<String?> slots) {
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;

  // weights based on category and slots
  Map<String?, double> categoryWeight = {};
  for (int i = 0; i < slots.length; i++) {
    categoryWeight[slots[i]] = 1 + (i * 0.5); // increment by 0.5
  }

  while (tasks.isNotEmpty) {
    // adjusted durations and sort tasks
    tasks.sort((a, b) {
      final double weightA = categoryWeight[a["Category"]] ?? 1.0;
      final double weightB = categoryWeight[b["Category"]] ?? 1.0;

      // duration -> minutes w/  adjusted durations
      final double adjustedDurationA =
          ((a["Duration"] as double) * 60) / weightA;
      final double adjustedDurationB =
          ((b["Duration"] as double) * 60) / weightB;

      final DateTime dateSetA = DateTime.parse(a["Date Set"]);
      final DateTime dateSetB = DateTime.parse(b["Date Set"]);

      // by shortest adjusted duration
      if (adjustedDurationA == adjustedDurationB) {
        return dateSetA.compareTo(dateSetB);
      }
      return adjustedDurationA.compareTo(adjustedDurationB);
    });

    // select task with shortest adjusted duration
    final task = tasks.removeAt(0);

    final int pid = task["pid"];
    final double durationInHours = task["Duration"] as double;
    final double weight = categoryWeight[task["Category"]] ?? 1.0;

    // duration -> mins
    final double adjustedDuration = (durationInHours * 60) / weight;


    int startTimeForTask = currentTime;
    int endTimeForTask = currentTime + adjustedDuration.ceil();

    // Debugging
    /* print("Task ID: $pid");
    print("Category: ${task["Category"]}");
    print("Original Duration (minutes): ${(durationInHours * 60).toInt()}");
    print("Adjusted Duration (minutes): ${adjustedDuration.ceil()}");
    print("Start Time: $startTimeForTask, End Time: $endTimeForTask"); */

    schedule.add(ScheduledProcess(
      pid: pid,
      startTime: startTimeForTask,
      endTime: endTimeForTask,
    ));

    currentTime = endTimeForTask; 
  }

  return schedule;
}


List<ScheduledProcess> staticWeightedMLQ(
    List<Map<String, dynamic>> tasks, int startTime, List<String?> slots) {
  // weight -> slots
  Map<String?, double> categoryWeights = {};
  for (int i = 0; i < slots.length; i++) {
    categoryWeights[slots[i]] = 1 + (i * 0.5); // increment by 0.5 
  }

  // priority queues for tasks
  List<Map<String, dynamic>> highPriorityQueue = [];
  List<Map<String, dynamic>> mediumPriorityQueue = [];
  List<Map<String, dynamic>> lowPriorityQueue = [];

  for (var task in tasks) {
    final int priority = task["Priority"] ?? 1; 
    final String? category = task["Category"];
    final double weight = categoryWeights[category] ?? 1.0;

    task["Weighted Duration"] =
        ((task["Duration"] as double) * 60) / weight; // adjust duration by weight

    // assign weights
    if (priority == 3) {
      highPriorityQueue.add(task);
    } else if (priority == 2) {
      mediumPriorityQueue.add(task);
    } else {
      lowPriorityQueue.add(task);
    }
  }

  // Shortest Weighted Job First logic
  void sortQueue(List<Map<String, dynamic>> queue) {
    queue.sort((a, b) {
      return (a["Weighted Duration"] as double)
          .compareTo(b["Weighted Duration"] as double);
    });
  }

  sortQueue(highPriorityQueue);
  sortQueue(mediumPriorityQueue);
  sortQueue(lowPriorityQueue);

  // schedule
  List<ScheduledProcess> schedule = [];
  int currentTime = startTime;


  List<List<Map<String, dynamic>>> priorityQueues = [
    highPriorityQueue,
    mediumPriorityQueue,
    lowPriorityQueue
  ];

  for (var queue in priorityQueues) {
    for (var task in queue) {
      if (task["Weighted Duration"] == null) {
        //print("Skipping task with invalid weighted duration: $task");
        continue;
      }

      final int pid = task["pid"];
      final int durationInMinutes = (task["Weighted Duration"] as double).ceil();

      int taskStartTime = currentTime;
      int taskEndTime = currentTime + durationInMinutes;

      // Debugging
      /* print("Task ID: $pid");
      print("Priority: ${task["Priority"]}");
      print("Category: ${task["Category"]}");
      print("Weighted Duration: $durationInMinutes");
      print("Start Time: $taskStartTime, End Time: $taskEndTime"); */

      schedule.add(ScheduledProcess(
        pid: pid,
        startTime: taskStartTime,
        endTime: taskEndTime,
      ));

      currentTime = taskEndTime; 
    }
  }

  return schedule;
}