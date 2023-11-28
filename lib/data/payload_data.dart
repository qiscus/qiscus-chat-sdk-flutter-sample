import 'package:equatable/equatable.dart';

class ResponseData with EquatableMixin {
  final String text;
  final List<Button> buttons;
  final String type;

  ResponseData({
    required this.text,
    required this.buttons,
    required this.type,
  });

  factory ResponseData.fromJson(Map<String, Object?> json) {
    final buttonsJson = json['buttons'] as List<dynamic>;
    final buttons = buttonsJson.map((buttonJson) => Button.fromJson(buttonJson)).toList();

    return ResponseData(
      text: json['text'] as String,
      buttons: buttons,
      type: json['type'] as String,
    );
  }

  @override
  List<Object?> get props => [text, buttons, type];
}

class Button with EquatableMixin {
  final String label;
  final String? postbackText;
  final String type;
  final Payload payload;

  Button({
    required this.label,
    this.postbackText,
    required this.type,
    required this.payload,
  });

  factory Button.fromJson(Map<String, dynamic> json) {
    return Button(
      label: json['label'] as String,
      postbackText: json['postback_text'] as String?,
      type: json['type'] as String,
      payload: Payload.fromJson(json['payload'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [label, postbackText, type, payload];
}

class Payload with EquatableMixin {
  final String url;
  final String method;
  final Object? payload;

  Payload({
    required this.url,
    required this.method,
    required this.payload,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      url: json['url'] as String,
      method: json['method'] as String,
      payload: json['payload'] as Object?,
    );
  }

  @override
  List<Object?> get props => [url, method, payload];
}