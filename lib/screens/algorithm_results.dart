import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/organising_tasks.dart';
import '../widgets/video_page.dart';



class AlgorithmResultFramework extends StatefulWidget {
  final String result;

  const AlgorithmResultFramework({super.key, required this.result});

  @override
  AlgorithmResultInterface createState() => AlgorithmResultInterface();
}

class AlgorithmResultInterface extends State<AlgorithmResultFramework> {
  String description = "Loading description...";

  @override
  void initState() {
    super.initState();
    loadDescription();
  }

  Future<void> loadDescription() async {
    try {
      String csvPath = "assets/explanations.csv"; 
      String fileData = await rootBundle.loadString(csvPath);
      List<String> rows = fileData.split("\n");

      for (String row in rows.skip(1)) {
        // skip the header row
        List<String> fields = row.split(",");
        if (fields.length >= 2 && fields[0].trim() == widget.result.trim()) {
          setState(() {
            description = fields[1].trim();
          });
          return;
        }
      }

      setState(() {
        description = "Description not found for the selected schedule.";
      });
    } catch (e) {
      setState(() {
        description = "Error loading description.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFC6BA), 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back arrow
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ),
            // Logo
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/sign_up.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            // Schedule Name
            const SizedBox(height: 20),
            Container(
              width: 250,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.result,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // Description
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            // Next / I'm still confused buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CategoryOrganisationFramework(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "NEXT",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigation to Video Players
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoPageFramework(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "I'M STILL CONFUSED",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
