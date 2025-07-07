import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';

final log = Logger.root
  ..level = Level.ALL
  ..onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

/// Path separator
///
final separator = Platform.pathSeparator;
Future<void> processDirectory(
  Directory directory, {
  List<String> ignoreDirs = const [],
  bool verbose = false,
  bool readonly = false,
}) async {
  var filesProcessed = 0;
  var symbolsRemoved = 0;

  try {
    log.info('###################################');
    log.info('Analyzing directory: ${directory.path}');
    log.info('###################################');
    // Process all files recursively
    await for (final entity in directory.list(recursive: true)) {
      if (ignoreDirs.any((dir) => entity.path.contains(dir))) {
        if (verbose) {
          log.info('Ignored [Dir]:  ${basename(entity.path)}');
        }
        continue;
      }
      if (entity is File &&
          (entity.path.endsWith('.dart') ||
              entity.path.endsWith('.yaml') ||
              entity.path.endsWith('.yml') ||
              entity.path.endsWith('.arb') ||
              entity.path.endsWith('.csv') ||
              entity.path.endsWith('.xml') ||
              entity.path.endsWith('.env') ||
              entity.path.endsWith('.json') ||
              entity.path.endsWith('.js') ||
              entity.path.endsWith('.html') ||
              entity.path.endsWith('.htm') ||
              entity.path.endsWith('.css') ||
              entity.path.endsWith('.txt') ||
              entity.path.endsWith('.md'))) {
        filesProcessed++;
        final removedCount = await processFile(entity, readonly: readonly);
        if (verbose && removedCount > 0) {
          log.info('Found tags[$removedCount]: ${basename(entity.path)}');
        } else if (verbose) {
          log.info('No Ai tags[$removedCount]: ${basename(entity.path)}');
        }
        symbolsRemoved += removedCount;
      } else if (verbose && entity is File) {
        log.info('Ignored [Ext]: ${basename(entity.path)}');
      }
    }

    log.info('###################################');
    log.info(readonly
        ? 'ReadOnly analysis complete!'
        : 'Analysis and modification complete!');
    log.info('Processed: $filesProcessed files.');
    log.info(readonly
        ? 'Found: $symbolsRemoved hidden/unicode symbols.'
        : 'Found and removed: $symbolsRemoved hidden/unicode symbols.');
    log.info('###################################');
  } catch (e) {
    log.warning('Error processing directory: $e');
  }
}

Future<int> processFile(File file, {bool readonly = false}) async {
  var symbolsRemoved = 0;
  try {
    final content = await file.readAsString();
    final (modifiedContent, removedCount) = aiReplacer(content);
    symbolsRemoved = removedCount;

    if (removedCount > 0 && !readonly) {
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
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    if (rune == 0x00A0 || //160, No-Break Space
            rune == 0x202F || //8239, Narrow NBSP
            rune == 0x3164 //12644, Hangul fillers
        ) {
      removedCount++;
      buffer.write(' ');
    } else if (rune == 0x00AD || //173, Soft hyphens
            rune == 0x2014 //8212, Long dash character
        ) {
      removedCount++;
      buffer.write('-');
    } else if (rune <= 0x1F ||
            (rune >= 0x7F && rune <= 0x9F) ||
            rune ==
                0x200B || //8203, Non-visible gap but still separates characters
            rune == 0x200C || //8204, Zero-Width Non-Joiner
            rune == 0x200D || //8205, Zero-Width joiners
            rune == 0xFEFF //65279, Zero-Width NBSP
        ) {
      // Save useful symbols
      if (rune == 0x09 || rune == 0x0A || rune == 0x0D) {
        buffer.writeCharCode(rune);
      } else {
        removedCount++;
      }
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return (buffer.toString(), removedCount);
}
