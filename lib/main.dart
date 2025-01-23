import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hive/node.dart';
import 'globals.dart';
import 'screens/welcome_screen.dart';
import 'schedule/algorithmInput.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AlgorithmInput.loadAlgorithmInputs();

  // path to CSV
  String csvPath = "assets/questionnaire.csv";
  String fileData = await rootBundle.loadString(csvPath);
  //print("CSV File Loaded:\n$fileData"); // debugggg

  List<String> rows = fileData.split("\n");
  for (int i = 1; i < rows.length; i++) {
    String row = rows[i].trim();
    if (row.isEmpty) continue; // skip the empty rows 

    List<String> itemInRow = row.split(",");
    if (itemInRow.length >= 11) {
      try {
        // makes it easier to debug during node creation
        Node node = Node(
          id: int.parse(itemInRow[0].trim()), // node ID
          description: itemInRow[10].trim(), // description (questions)
          options: [
            Option(
              //index [0] in poptions
              text: itemInRow[1].trim(), // option 1 text
              link: int.parse(itemInRow[2].trim()), // option 1 link
              process: itemInRow[3].trim(), // process 1 text
            ),
            Option(
              //index[1]
              text: itemInRow[4].trim(), // option 2 text
              link: int.parse(itemInRow[5].trim()), // option 2 link
              process: itemInRow[6].trim(), // process 2 text
            ),
            Option(
              //index[2]
              text: itemInRow[7].trim(), // option 3 text
              link: int.parse(itemInRow[8].trim()), // option 3 link
              process: itemInRow[9].trim(), // process 3 text
            ),
          ],
        );
        decisionMap.add(node);
      } catch (e) {
        print(
            "Error parsing row $i: $e"); //this dbug is needed cos you indexed incorrectly. 11 rows not 12
      }
    } else {
      print("Row $i is incomplete or a lil bit off in: $row");
    }
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WelcomeScreen(),
  ));
}





