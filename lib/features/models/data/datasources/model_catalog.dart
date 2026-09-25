import '../../domain/entities/llm_model.dart';

/// Public (no Hugging Face token needed) models that run on phones.
/// Add an entry here to offer another model; nothing else needs to change.
abstract final class ModelCatalog {
  static const _hf = 'https://huggingface.co/litert-community';

  static const models = [
    LlmModel(
      id: 'qwen3-0.6b',
      name: 'Qwen3 0.6B',
      description: 'Best quality. Needs a modern 64-bit (arm64) phone.',
      sizeLabel: '586 MB',
      url: '$_hf/Qwen3-0.6B/resolve/main/Qwen3-0.6B.litertlm',
      fileName: 'Qwen3-0.6B.litertlm',
      family: LlmFamily.qwen3,
      format: LlmFormat.litertlm,
      recommended: true,
    ),
    LlmModel(
      id: 'qwen2.5-0.5b',
      name: 'Qwen 2.5 0.5B Instruct',
      description: 'Good all-rounder. Works on every Android device and emulator.',
      sizeLabel: '0.5 GB',
      url: '$_hf/Qwen2.5-0.5B-Instruct/resolve/main/'
          'Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task',
      fileName: 'Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task',
      family: LlmFamily.qwen,
      format: LlmFormat.task,
      maxTokens: 1024,
    ),
    LlmModel(
      id: 'smollm-135m',
      name: 'SmolLM 135M Instruct',
      description: 'Tiny and fast, for low-end devices. Basic answers.',
      sizeLabel: '135 MB',
      url: '$_hf/SmolLM-135M-Instruct/resolve/main/'
          'SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task',
      fileName: 'SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task',
      family: LlmFamily.general,
      format: LlmFormat.task,
      maxTokens: 1024,
      topP: 0.9,
    ),
  ];
}
