import 'package:equatable/equatable.dart';

/// Prompt/template family (mapped to flutter_gemma's ModelType in data layer).
enum LlmFamily { qwen3, qwen, general }

/// On-disk format, which also decides the inference engine:
/// `.litertlm` -> LiteRT-LM (arm64 only), `.task` -> MediaPipe (all ABIs).
enum LlmFormat { litertlm, task }

/// A downloadable on-device model and how to run it.
final class LlmModel extends Equatable {
  const LlmModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sizeLabel,
    required this.url,
    required this.fileName,
    required this.family,
    required this.format,
    this.maxTokens = 2048,
    this.maxOutputTokens = 512,
    this.temperature = 0.7,
    this.topK = 40,
    this.topP = 0.95,
    this.recommended = false,
  });

  final String id;
  final String name;
  final String description;
  final String sizeLabel;
  final String url;
  final String fileName;
  final LlmFamily family;
  final LlmFormat format;

  /// Context window (prompt + history + reply).
  final int maxTokens;
  final int maxOutputTokens;
  final double temperature;
  final int topK;
  final double topP;
  final bool recommended;

  @override
  List<Object?> get props => [id];
}

enum ModelInstallStatus { notInstalled, downloading, installed }
