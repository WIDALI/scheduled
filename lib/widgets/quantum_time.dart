import 'dart:core';
import 'package:flutter/material.dart';

import '../widgets/organising_tasks.dart';
import '../schedule/task_input.dart';


import 'package:shared_preferences/shared_preferences.dart';



class QuantumTimeFramework extends StatefulWidget {
  const QuantumTimeFramework({Key? key}) : super(key: key);

  @override
  QuantumTimeInterface createState() => QuantumTimeInterface();
}

class QuantumTimeInterface extends State<QuantumTimeFramework> {
  double quantumTime = 0.5; // default quantum (30 mins)

  Widget _buildTimeButton(double timeValue, String label) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          quantumTime = timeValue;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('quantumTime', quantumTime);

        //print("Saved Quantum Time: $quantumTime"); 
      },
      child: Container(
        width: 200, 
        height: 125,
        decoration: BoxDecoration(
          color: quantumTime == timeValue
              ? const Color(0xFFB7B09C) // selected 
              : const Color(0xFFCFC6BA), // unselected 
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: quantumTime == timeValue
                  ? Colors.white 
                  : const Color(0xFF6C584C), 
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryOrganisationFramework(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Question Box
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDAD5C7), 
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                "What is the longest time you can study for without breaks?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C584C), 
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Quantum optionsin 3x2 Layout
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeButton(0.25, "15 mins"),
                    _buildTimeButton(0.5, "30 mins\n(default)"),
                    _buildTimeButton(0.75, "45 mins"),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeButton(1.0, "1 hour"),
                    _buildTimeButton(1.5, "1 hr 30"),
                    _buildTimeButton(2.0, "2 hours"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Next Button
            ElevatedButton(
              onPressed: () {
                if (quantumTime > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaskInputFramework(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a quantum time."),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C584C), 
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "NEXT",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

