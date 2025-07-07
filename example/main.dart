import '../bin/ai_tags_remover.dart';

void main(List<String> args) async {
  // execute(['--verbose', '--readonly']);

  /// Analyse current project.
  /// will find Hidden symbols in [ai_tags_remover_test.dart]
  execute(['--readonly']);
}
