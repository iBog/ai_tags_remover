import 'package:ai_tags_remover/ai_tags_remover.dart';
import 'package:test/test.dart';

void main() {
  group('aiReplacer', () {
    final testCases = {
      'ChatGPT is an amazing LLM developed by OpenAI. 🤖🧠✨': ('ChatGPT is an amazing LLM developed by OpenAI. 🤖🧠✨', 0),
      'Hello\u0000World\u0001! This has \u000Bsome \u007Fcontrol characters.': ('HelloWorld! This has some control characters.', 4),
      'Some text with \u0085NEL and \u009B CSI characters.': ('Some text with NEL and  CSI characters.', 2),
      'This\u200Bis\u200Ca\u200Dtest\uFEFFof\u200Bzero\u200Bwidth\u200Ccharacters.': ('Thisisatestofzerowidthcharacters.', 7),
      'Generative AI models like DALL-E and Midjourney create art.\u0005🤖🧠✨\u200B': ('Generative AI models like DALL-E and Midjourney create art.🤖🧠✨', 2),
      'A robot asked me about my neural network.\u0007⚙️💡': ('A robot asked me about my neural network.⚙️💡', 1),
      'No AI terms here, just plain text.': ('No AI terms here, just plain text.', 0),
      'Artificial Intelligence is transforming industries.': ('Artificial Intelligence is transforming industries.', 0),
      'Deep Learning algorithms are complex.': ('Deep Learning algorithms are complex.', 0),
      'This sentence contains A.I. and GPT-3.': ('This sentence contains A.I. and GPT-3.', 0),
      'The algorithm for this Generative model is new.': ('The algorithm for this Generative model is new.', 0),
      'Stable Diffusion created this image.': ('Stable Diffusion created this image.', 0),
      'Line 1\r\nLine 2\rLine 3\u0085Line 4': ('Line 1\r\nLine 2\rLine 3Line 4', 1),
      'Data\tScience\tmodels': ('Data\tScience\tmodels', 0),
      'Text with\u00A0non-breaking\u202Fspace.': ('Text with non-breaking space.', 2),
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
}