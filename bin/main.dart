import 'dart:io';

import 'package:ai_tags_remover/ai_tags_remover.dart';
import 'package:args/args.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('ignore-dirs', defaultsTo: '')
    ..addFlag('version', negatable: false);
  final argResults = parser.parse(args);

  if (argResults['version']) {
    log.info('ai_tags_remover v0.7.0');
    return;
  }

  final directory = argResults.rest.isNotEmpty ? argResults.rest[0] : '.';
  final ignoreDirs =
      argResults['ignore-dirs'].split(',').map((e) => e.trim()).toList();

  await processDirectory(Directory(directory), ignoreDirs: ignoreDirs);
}
