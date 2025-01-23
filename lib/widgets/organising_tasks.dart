import 'dart:core';
import 'package:flutter/material.dart';
import '../quiz/quiz.dart';
import '../widgets/quantum_time.dart';

import 'package:shared_preferences/shared_preferences.dart';



class CategoryOrganisationFramework extends StatefulWidget {
  const CategoryOrganisationFramework({super.key});

  @override
  CategoryOrganisationInterface createState() =>
      CategoryOrganisationInterface();
}

class CategoryOrganisationInterface
    extends State<CategoryOrganisationFramework> {
  final List<String> categories = [
    "ASSIGNMENTS",
    "COURSEWORK",
    "GROUP WORK",
    "EXAMS/QUIZZES",
    "PRACTICAL WORK"
  ];
  final List<String?> slots = List.generate(5, (_) => null);

  void onAcceptCategory(int slotIndex, String category) {
    setState(() {
      // remove category from current position
      int? previousSlotIndex = slots.indexOf(category);
      if (previousSlotIndex != -1) {
        slots[previousSlotIndex] = null;
      }
      slots[slotIndex] = category;
    });
    saveSlots(); 
    //print("Saving the following slots to SharedPreferences: $slots");
  }

  Future<void> saveSlots() async {
    final prefs = await SharedPreferences.getInstance();
    //print("SharedPreferences initialized"); 
    await prefs.setStringList(
      'categorySlots',
      slots.map((slot) => slot ?? "").toList(), // convert nulls to empty strings
    );
    //print("Saved Slots: $slots"); 

    //final verifySlots = prefs.getStringList('categorySlots') ?? [];
    //print("Verified Slots in SharedPreferences: $verifySlots");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 255, 255), 
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 255, 255, 255), 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudyQuizFramework(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            const Text(
              "When completing these academic tasks, which ones require the most effort, and which ones require the least?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C584C), 
              ),
              textAlign: TextAlign.center,
            ),
            // Category labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: const [
                    Text(
                      "1",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C584C), // Dark beige/brown for text
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "LOW\nEFFORT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C584C), // Dark beige/brown for text
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: const [
                    Text(
                      "5",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C584C), // Dark beige/brown for text
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "HIGH\nEFFORT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C584C), // Dark beige/brown for text
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Drag target slots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return DragTarget<String>(
                  onAcceptWithDetails: (details) =>
                      onAcceptCategory(index, details.data),
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 150,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: slots[index] == null
                            ? const Color.fromRGBO(218, 213, 199, 1) // empty 
                            : const Color.fromRGBO(183, 176, 156, 1), //filled 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF6C584C), width: 1),
                      ),
                      // category text
                      child: Text(
                        slots[index] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C584C), 
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            // draggable category options
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: categories
                  .where((category) => !slots.contains(category))
                  .map((category) {
                return Draggable<String>( //didn't know this existed
                  data: category,
                  feedback: Material(
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB7B09C), 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF6C584C), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                Color(0xFF6C584C), 
                          ),
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: Container(
                      width: 150,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDAD5C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                Color(0xFF6C584C),
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAD5C7), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C584C), 
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Next 
            ElevatedButton(
              onPressed: () async {
                // save the current slot positions
                await saveSlots();
                //print("Final Slots Saved: $slots"); // Debugging the saved slots

                // Navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuantumTimeFramework(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF6C584C),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded edges
                ),
              ),
              child: const Text(
                "NEXT",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold, // Bold for emphasis
                  color: Colors.white, // White text for contrast
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


