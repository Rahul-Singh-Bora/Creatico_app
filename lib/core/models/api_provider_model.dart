// lib/core/models/api_provider_model.dart

class ApiProviderModel {
  final String id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final String? model;
  final RequestConfigModel requestConfig;
  final ResponseConfigModel responseConfig;
  final StreamingConfigModel? streamingConfig;
  final Map<String, String>? headers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiProviderModel({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    this.model,
    required this.requestConfig,
    required this.responseConfig,
    this.streamingConfig,
    this.headers,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiProviderModel.fromJson(Map<String, dynamic> json) {
    return ApiProviderModel(
      id: json['id'],
      name: json['name'],
      baseUrl: json['baseUrl'],
      apiKey: json['apiKey'],
      model: json['model'],
      requestConfig: RequestConfigModel.fromJson(json['requestConfig']),
      responseConfig: ResponseConfigModel.fromJson(json['responseConfig']),
      streamingConfig: json['streamingConfig'] != null 
          ? StreamingConfigModel.fromJson(json['streamingConfig'])
          : null,
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'])
          : null,
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'model': model,
      'requestConfig': requestConfig.toJson(),
      'responseConfig': responseConfig.toJson(),
      'streamingConfig': streamingConfig?.toJson(),
      'headers': headers,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ApiProviderModel copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiKey,
    String? model,
    RequestConfigModel? requestConfig,
    ResponseConfigModel? responseConfig,
    StreamingConfigModel? streamingConfig,
    Map<String, String>? headers,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApiProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      requestConfig: requestConfig ?? this.requestConfig,
      responseConfig: responseConfig ?? this.responseConfig,
      streamingConfig: streamingConfig ?? this.streamingConfig,
      headers: headers ?? this.headers,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RequestConfigModel {
  final String method;
  final String endpoint;
  final String bodyTemplate;
  final String? contentType;
  final String authType;
  final String? authHeaderName;
  final Map<String, String>? queryParams;

  RequestConfigModel({
    required this.method,
    required this.endpoint,
    required this.bodyTemplate,
    this.contentType,
    required this.authType,
    this.authHeaderName,
    this.queryParams,
  });

  factory RequestConfigModel.fromJson(Map<String, dynamic> json) {
    return RequestConfigModel(
      method: json['method'],
      endpoint: json['endpoint'],
      bodyTemplate: json['bodyTemplate'],
      contentType: json['contentType'],
      authType: json['authType'],
      authHeaderName: json['authHeaderName'],
      queryParams: json['queryParams'] != null
          ? Map<String, String>.from(json['queryParams'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'endpoint': endpoint,
      'bodyTemplate': bodyTemplate,
      'contentType': contentType,
      'authType': authType,
      'authHeaderName': authHeaderName,
      'queryParams': queryParams,
    };
  }
}

class ResponseConfigModel {
  final String contentPath;
  final String? errorPath;
  final bool isStreaming;

  ResponseConfigModel({
    required this.contentPath,
    this.errorPath,
    required this.isStreaming,
  });

  factory ResponseConfigModel.fromJson(Map<String, dynamic> json) {
    return ResponseConfigModel(
      contentPath: json['contentPath'],
      errorPath: json['errorPath'],
      isStreaming: json['isStreaming'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentPath': contentPath,
      'errorPath': errorPath,
      'isStreaming': isStreaming,
    };
  }
}

class StreamingConfigModel {
  final String? eventType;
  final String? dataPrefix;
  final String? stopSequence;
  final String contentPath;
  final String? deltaPath;

  StreamingConfigModel({
    this.eventType,
    this.dataPrefix,
    this.stopSequence,
    required this.contentPath,
    this.deltaPath,
  });

  factory StreamingConfigModel.fromJson(Map<String, dynamic> json) {
    return StreamingConfigModel(
      eventType: json['eventType'],
      dataPrefix: json['dataPrefix'],
      stopSequence: json['stopSequence'],
      contentPath: json['contentPath'],
      deltaPath: json['deltaPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'dataPrefix': dataPrefix,
      'stopSequence': stopSequence,
      'contentPath': contentPath,
      'deltaPath': deltaPath,
    };
  }
}

// Predefined provider templates for Flutter
class ProviderTemplates {
  static const Map<String, Map<String, dynamic>> templates = {
    'openai': {
      'name': 'OpenAI',
      'baseUrl': 'https://api.openai.com',
      'model': 'gpt-4o-mini',
      'requestConfig': {
        'method': 'POST',
        'endpoint': '/v1/chat/completions',
        'bodyTemplate': '{"model":"{{model}}","messages":[{"role":"user","content":"{{prompt}}"}],"stream":{{stream}},"temperature":{{temperature}},"max_tokens":{{maxTokens}}}',
        'authType': 'bearer',
      },
      'responseConfig': {
        'contentPath': 'choices.0.message.content',
        'errorPath': 'error.message',
        'isStreaming': true,
      },
      'streamingConfig': {
        'dataPrefix': 'data: ',
        'stopSequence': '[DONE]',
        'contentPath': 'choices.0.delta.content',
      }
    },
    'groq': {
      'name': 'Groq',
      'baseUrl': 'https://api.groq.com',
      'model': 'llama-3.1-70b-versatile',
      'requestConfig': {
        'method': 'POST',
        // Groq exposes OpenAI-compatible endpoints under /openai/v1
        'endpoint': '/openai/v1/chat/completions',
        'bodyTemplate': '{"model":"{{model}}","messages":[{"role":"user","content":"{{prompt}}"}],"stream":{{stream}},"temperature":{{temperature}},"max_tokens":{{maxTokens}}}',
        'authType': 'bearer',
      },
      'responseConfig': {
        'contentPath': 'choices.0.message.content',
        'errorPath': 'error.message',
        'isStreaming': true,
      },
      'streamingConfig': {
        'dataPrefix': 'data: ',
        'stopSequence': '[DONE]',
        'contentPath': 'choices.0.delta.content',
      }
    },
    'anthropic': {
      'name': 'Anthropic Claude',
      'baseUrl': 'https://api.anthropic.com',
      'model': 'claude-3-sonnet-20240229',
      'requestConfig': {
        'method': 'POST',
        'endpoint': '/v1/messages',
        'bodyTemplate': '{"model":"{{model}}","messages":[{"role":"user","content":"{{prompt}}"}],"max_tokens":{{maxTokens}},"stream":{{stream}}}',
        'authType': 'header',
        'authHeaderName': 'x-api-key',
      },
      'responseConfig': {
        'contentPath': 'content.0.text',
        'errorPath': 'error.message',
        'isStreaming': true,
      },
      'streamingConfig': {
        'eventType': 'content_block_delta',
        'dataPrefix': 'data: ',
        'contentPath': 'delta.text',
      }
    },
    'generic': {
      'name': 'Generic API',
      'baseUrl': 'https://your-api.com',
      'requestConfig': {
        'method': 'POST',
        'endpoint': '/api/generate',
        'bodyTemplate': '{"prompt":"{{prompt}}","model":"{{model}}"}',
        'authType': 'bearer',
      },
      'responseConfig': {
        'contentPath': 'text',
        'errorPath': 'error',
        'isStreaming': false,
      }
    }
  };
}
