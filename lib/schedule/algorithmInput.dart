import 'dart:convert';
import 'package:flutter/services.dart';

class AlgorithmInput {
  static Map<String, dynamic> algorithmInputs = {};
  // Map defining required inputs for each algorithm
  static Future<void> loadAlgorithmInputs() async {
    // try {
    String jsonString = await rootBundle.loadString('assets/task_input.json');

    algorithmInputs = json.decode(jsonString);

    // } catch (e) {
    //   print('JSON load failed');
    // }
  }

  static bool contains(String algorithmName, String field) {
    //print(algorithmInputs.keys);
    for (var attribute in algorithmInputs[algorithmName]) {
      if (attribute == field) return true;
    }
    return false;
  }
}
