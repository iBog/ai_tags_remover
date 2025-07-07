import 'dart:io';

import 'package:ai_tags_remover/ai_tags_remover.dart';

void main(List<String> args) async {
  if (args.contains('--version')) {
    log.info('ai_tags_remover v0.7.0');
    return;
  }
  final directory = args.isNotEmpty ? args[0] : '.';
  await processDirectory(Directory(directory));
}
