import 'dart:io';

import 'package:logging/logging.dart';

final log = Logger.root..level = Level.ALL;

/// Path separator
///
final separator = Platform.pathSeparator;
Future<void> processDirectory(Directory directory) async {
  var filesProcessed = 0;
  var symbolsRemoved = 0;

  try {
    log.info('Analyzing directory: ${directory.path}');

    // Process all files recursively
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File &&
          (entity.path.endsWith('.dart') ||
              entity.path.endsWith('.yaml') ||
              entity.path.endsWith('.md'))) {
        filesProcessed++;
        final removedCount = await processFile(entity);
        symbolsRemoved += removedCount;
      }
    }

    log.info('Analysis and modification complete!');
    log.info('Processed $filesProcessed files.');
    log.info('Found and removed $symbolsRemoved hidden symbols.');
  } catch (e) {
    log.warning('Error processing directory: $e');
  }
}

Future<int> processFile(File file) async {
  var symbolsRemoved = 0;
  try {
    final content = await file.readAsString();
    final (modifiedContent, removedCount) = aiReplacer(content);
    symbolsRemoved = removedCount;

    if (modifiedContent != content) {
      await file.writeAsString(modifiedContent);
      log.info('Modified: ${file.path}');
    }
  } catch (e) {
    log.warning('Error processing file ${file.path}: $e');
  }
  return symbolsRemoved;
}

(String, int) aiReplacer(String text) {
  var removedCount = 0;
  final modifiedText = text.replaceAllMapped(
    RegExp(r'[\x00-\x1F\x7F\x80-\x9F\u200B\u200C\u200D\uFEFF\u00A0\u202F]'),
    (Match m) {
      final char = m.group(0)!;
      final rune = char.runes.first;
      // Replace spacing-like symbols with spaces
      if (rune == 0x00A0 || rune == 0x202F) {
        removedCount++;
        return ' ';
      }
      // keeping useful symbols
      if (rune == 0x09 || rune == 0x0A || rune == 0x0D) {
        return char;
      }
      removedCount++;
      return '';
    },
  );
  return (modifiedText, removedCount);
}
