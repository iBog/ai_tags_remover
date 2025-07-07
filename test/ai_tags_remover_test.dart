import 'dart:io';

import 'package:ai_tags_remover/ai_tags_remover.dart';
import 'package:test/test.dart';

void main() {
  group('aiReplacer', () {
    final testCases = {
      'AI slop refers to the widespread output of low-effort, auto-generated content produced by large language models with minimal human intervention. This content is typically optimized for volume and surface-level coherence, not depth or originality. While it may appear grammatically correct and well-structured, it lacks semantic nuance, critical insight, and meaningful context—hallmarks of authentic human writing. A key concern with AI slop is its reliance on invisible and obscure Unicode characters. Elements like zero-width spaces (), soft hyphens (­), zero-width joiners (‍), and Hangul fillers (ㅤ) can be subtly inserted into the text. These characters are often not visible to readers but can affect how content is parsed, indexed, or rendered by software systems. They can cause strings that look identical to behave differently, breaking search functionality, analytics pipelines, and even bypassing filters designed to detect AI-generated content. In some cases, these characters are introduced unintentionally by generative models trying to mimic formatting patterns found in training data. In others, they are used deliberately to manipulate content visibility or evade moderation tools. Either way, their presence adds another layer of complexity and risk to already questionable content. As the volume of AI-generated material increases, so too does the risk that digital spaces become saturated with this kind of content—clogging search results, diminishing trust in online sources, and making it harder for human-created material to stand out. AI slop isn\'t just a nuisance—it\'s a structural challenge for the future of online information integrity.':
          (
        'AI slop refers to the widespread output of low-effort, auto-generated content produced by large language models with minimal human intervention. This content is typically optimized for volume and surface-level coherence, not depth or originality. While it may appear grammatically correct and well-structured, it lacks semantic nuance, critical insight, and meaningful context-hallmarks of authentic human writing. A key concern with AI slop is its reliance on invisible and obscure Unicode characters. Elements like zero-width spaces (), soft hyphens (-), zero-width joiners (), and Hangul fillers ( ) can be subtly inserted into the text. These characters are often not visible to readers but can affect how content is parsed, indexed, or rendered by software systems. They can cause strings that look identical to behave differently, breaking search functionality, analytics pipelines, and even bypassing filters designed to detect AI-generated content. In some cases, these characters are introduced unintentionally by generative models trying to mimic formatting patterns found in training data. In others, they are used deliberately to manipulate content visibility or evade moderation tools. Either way, their presence adds another layer of complexity and risk to already questionable content. As the volume of AI-generated material increases, so too does the risk that digital spaces become saturated with this kind of content-clogging search results, diminishing trust in online sources, and making it harder for human-created material to stand out. AI slop isn\'t just a nuisance-it\'s a structural challenge for the future of online information integrity.',
        6
      ),
      'ChatGPT is an amazing LLM developed by OpenAI. 🤖🧠✨': (
        'ChatGPT is an amazing LLM developed by OpenAI. 🤖🧠✨',
        0
      ),
      'Hello\u0000World\u0001! This has \u000Bsome \u007Fcontrol characters.': (
        'HelloWorld! This has some control characters.',
        4
      ),
      'Some text with \u0085NEL and \u009B CSI characters.': (
        'Some text with NEL and  CSI characters.',
        2
      ),
      'This\u200Bis\u200Ca\u200Dtest\uFEFFof\u200Bzero\u200Bwidth\u200Ccharacters.':
          ('Thisisatestofzerowidthcharacters.', 7),
      'Generative AI models like DALL-E and Midjourney create art.\u0005🤖🧠✨\u200B':
          (
        'Generative AI models like DALL-E and Midjourney create art.🤖🧠✨',
        2
      ),
      'A robot asked me about my neural network.\u0007⚙️💡': (
        'A robot asked me about my neural network.⚙️💡',
        1
      ),
      'No AI terms here, just plain text.': (
        'No AI terms here, just plain text.',
        0
      ),
      'Artificial Intelligence is transforming industries.': (
        'Artificial Intelligence is transforming industries.',
        0
      ),
      'Deep Learning algorithms are complex.': (
        'Deep Learning algorithms are complex.',
        0
      ),
      'This sentence contains A.I. and GPT-3.': (
        'This sentence contains A.I. and GPT-3.',
        0
      ),
      'The algorithm for this Generative model is new.': (
        'The algorithm for this Generative model is new.',
        0
      ),
      'Stable Diffusion created this image.': (
        'Stable Diffusion created this image.',
        0
      ),
      'Line 1\r\nLine 2\rLine 3\u0085Line 4': (
        'Line 1\r\nLine 2\rLine 3Line 4',
        1
      ),
      'Data\tScience\tmodels': ('Data\tScience\tmodels', 0),
      'Text with\u00A0non-breaking\u202Fspace.': (
        'Text with non-breaking space.',
        2
      ),
    };

    test('should remove hidden symbols correctly and count them', () {
      for (final entry in testCases.entries) {
        final input = entry.key;
        final expected = entry.value;
        final (result, count) = aiReplacer(input);
        expect(result, equals(expected.$1),
            reason:
                'Failed on input: "${input.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"');
        expect(count, equals(expected.$2),
            reason:
                'Failed on input: "${input.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"');
      }
    });
  });

  group('processDirectory', () {
    test('should ignore specified directories', () async {
      // 1. Create a temporary directory structure
      final tempDir =
          await Directory.systemTemp.createTemp('ai_tags_remover_test');
      final ignoredDir = Directory('${tempDir.path}${separator}generated');
      await ignoredDir.create();

      final ignoredFile =
          File('${ignoredDir.path}${separator}ignored_file.dart');
      await ignoredFile.writeAsString('Hello\u200BWorld!');

      final processedFile =
          File('${tempDir.path}${separator}processed_file.dart');
      await processedFile.writeAsString('Hello\u200BWorld!');

      // 2. Process the directory with the ignore list
      await processDirectory(tempDir, ignoreDirs: ['generated']);

      // 3. Check that the ignored file is untouched
      final ignoredFileContent = await ignoredFile.readAsString();
      expect(ignoredFileContent, equals('Hello\u200BWorld!'));

      // 4. Check that the other file is processed
      final processedFileContent = await processedFile.readAsString();
      expect(processedFileContent, equals('HelloWorld!'));

      // 5. Clean up
      await tempDir.delete(recursive: true);
    });
  });
}
