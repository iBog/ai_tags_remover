import 'dart:io';

import 'package:ai_tags_remover/ai_tags_remover.dart';
import 'package:args/args.dart';

void main(List<String> args) async {
  await execute(args);
}

/// Executes the AI tags remover.
///
/// Command-line arguments:
/// ignore-dirs - List of ignoring dirs separated by commas
/// --version - App version
/// --readonly - Do not apply file changes, only analysis
/// --verbose - Print report for every processed file
Future<void> execute(List<String> args) async {
  final parser = ArgParser()
    ..addOption('ignore-dirs',
        defaultsTo: 'generated/intl,.git,.dart_tool,.idea')
    ..addFlag('version', negatable: false)
    ..addFlag('readonly', negatable: false)
    ..addFlag('verbose', negatable: false);
  final argResults = parser.parse(args);
  var isVerbose = argResults['verbose'];
  var isReadonly = argResults['readonly'];
  if (argResults['version']) {
    log.info('ai_tags_remover v0.8.1');
    return;
  }

  final directory = argResults.rest.isNotEmpty ? argResults.rest[0] : '.';
  final ignoreDirs = (argResults['ignore-dirs'] as String)
      .split(',')
      .map((e) => e.trim())
      .toList();

  await processDirectory(Directory(directory),
      ignoreDirs: ignoreDirs, verbose: isVerbose, readonly: isReadonly);
}
