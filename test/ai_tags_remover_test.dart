import 'package:ai_tags_remover/ai_tags_remover.dart';
import 'package:test/test.dart';

void main() {
  group('aiReplacer', () {
    final testCases = {
      // Text with some common AI terms and emojis
      'ChatGPT is an amazing LLM developed by OpenAI. 🤖🧠✨':
          'ChatGPT is an amazing LLM developed by OpenAI. 🤖🧠✨',
      // Text with ASCII control characters
      'Hello\u0000World\u0001! This has \u000Bsome \u007Fcontrol characters.':
          'HelloWorld! This has some control characters.',
      // Text with C1 control codes
      'Some text with \u0085NEL and \u009B CSI characters.':
          'Some text with NEL and  CSI characters.',
      // Text with zero-width characters
      'This\u200Bis\u200Ca\u200Dtest\uFEFFof\u200Bzero\u200Bwidth\u200Ccharacters.':
          'Thisisatestofzerowidthcharacters.',
      // Mixed example with AI terms, emojis, and invisible characters
      'Generative AI models like DALL-E and Midjourney create art.\u0005🤖🧠✨\u200B':
          'Generative AI models like DALL-E and Midjourney create art.🤖🧠✨',
      'A robot asked me about my neural network.\u0007⚙️💡':
          'A robot asked me about my neural network.⚙️💡',
      'No AI terms here, just plain text.':
          'No AI terms here, just plain text.',
      'Artificial Intelligence is transforming industries.':
          'Artificial Intelligence is transforming industries.',
      'Deep Learning algorithms are complex.':
          'Deep Learning algorithms are complex.',
      'This sentence contains A.I. and GPT-3.':
          'This sentence contains A.I. and GPT-3.',
      'The algorithm for this Generative model is new.':
          'The algorithm for this Generative model is new.',
      'Stable Diffusion created this image.':
          'Stable Diffusion created this image.',
      // Text with mixed newlines for testing normalization
      'Line 1\r\nLine 2\rLine 3\u0085Line 4': 'Line 1\r\nLine 2\rLine 3Line 4',
      // Text with tabs for testing normalization
      'Data\tScience\tmodels': 'Data\tScience\tmodels',
      // Text with special spaces
      'Text with\u00A0non-breaking\u202Fspace.': 'Text with non-breaking space.',
    };

    test('should remove hidden symbols correctly', () {
      for (final entry in testCases.entries) {
        final input = entry.key;
        final expected = entry.value;
        final result = aiReplacer(input);
        expect(result, equals(expected),
            reason:
                'Failed on input: "${input.replaceAll('\n', '\\n').replaceAll('\r', '\\r')}"');
      }
    });
  });
}