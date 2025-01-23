import 'package:hive/hive.dart';

part 'node.g.dart';

@HiveType(typeId: 0) // Assign a unique type ID
class Node {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final List<Option> options; // list of options for branching

  Node({
    required this.id,
    required this.description,
    this.options = const [],
  });

  // create a Node from a CSV row
  factory Node.fromCsv(List<String> csvRow) {
    // validate and parse Node ID
    final id = int.tryParse(csvRow[0]) ?? -1;

    // parse the description
    final description = csvRow.length > 9 && csvRow[9].trim().isNotEmpty
        ? csvRow[9].trim()
        : "No Description";

    // parse options
    final options = <Option>[];
    for (int i = 1; i <= 3; i++) {
      final optionTextIndex = (3 * i) - 2; // text columns: 1, 4, 7
      final optionLinkIndex = (3 * i) - 1; // link columns: 2, 5, 8
      final optionProcessIndex = 3 * i;    // process columns: 3, 6, 9

      if (optionTextIndex < csvRow.length &&
          optionLinkIndex < csvRow.length &&
          optionProcessIndex < csvRow.length) {
        final text = csvRow[optionTextIndex].trim();
        final link = int.tryParse(csvRow[optionLinkIndex].trim()) ?? -1;
        final process = csvRow[optionProcessIndex].trim();

        if (text.isNotEmpty) {
          options.add(Option(text: text, link: link, process: process));
        }
      }
    }

    return Node(
      id: id,
      description: description,
      options: options,
    );
  }
}

@HiveType(typeId: 1) // Assign a unique type ID for Option
class Option {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final int link;

  @HiveField(2)
  final String process;

  Option({
    required this.text,
    required this.link,
    this.process = "",
  });
}