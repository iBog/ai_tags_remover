

import 'dart:io';

import 'package:logging/logging.dart';

final log = Logger.root..level = Level.ALL;

/// Path separator
///
final separator = Platform.pathSeparator;
Future<void> processDirectory(Directory directory) async {
  try {
    log.info('Analyzing directory: ${directory.path}');

    // Process all files recursively
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File &&
          (entity.path.endsWith('.dart') || entity.path.endsWith('.yaml'))) {
        await processFile(entity);
      }
    }

    log.info('Analysis and modification complete!');
  } catch (e) {
    log.warning('Error processing directory: $e');
  }
}

Future<void> processFile(File file) async {
  try {
    final content = await file.readAsString();
    final modifiedContent = aiReplacer(content);

    if (modifiedContent != content) {
      await file.writeAsString(modifiedContent);
      log.info('Modified: ${file.path}');
    }
  } catch (e) {
    log.warning('Error processing file ${file.path}: $e');
  }
}

String aiReplacer(String text) {
  return text.replaceAllMapped(
    RegExp(r'[\x00-\x1F\x7F\x80-\x9F\u200B\u200C\u200D\uFEFF\u00A0\u202F]'),
    (Match m) {
      final char = m.group(0)!;
      final rune = char.runes.first;
      // Replace spacing-like symbols with spaces
      if (rune == 0x00A0 || rune == 0x202F) {
        return ' ';
      }
      // keeping useful symbols
      if (rune == 0x09 || rune == 0x0A || rune == 0x0D) {
        return char;
      }
      return '';
    },
  );
}
