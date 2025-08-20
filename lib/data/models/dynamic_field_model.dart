// data/models/dynamic_field_model.dart
class DynamicField {
  final String name;
  final String type;
  final bool required;
  final String description;
  final String? format;
  final int? minLength;
  final int? maxLength;
  final int? minValue;
  final int? maxValue;
  final int? minItems;
  final int? maxItems;
  final dynamic example;
  final dynamic defaultValue;
  final dynamic value;
  final String? keyFormat;
  final String? valueFormat;

  DynamicField({
    required this.name,
    required this.type,
    required this.required,
    required this.description,
    this.format,
    this.minLength,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.minItems,
    this.maxItems,
    this.example,
    this.defaultValue,
    this.value,
    this.keyFormat,
    this.valueFormat,
  });

  factory DynamicField.fromJson(Map<String, dynamic> json) {
    return DynamicField(
      name: json['name'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? false,
      description: json['description'] as String,
      format: json['format'] as String?,
      minLength: json['min_length'] as int?,
      maxLength: json['max_length'] as int?,
      minValue: json['min_value'] as int?,
      maxValue: json['max_value'] as int?,
      minItems: json['min_items'] as int?,
      maxItems: json['max_items'] as int?,
      example: json['example'],
      defaultValue: json['default_value'],
      value: json['value'] ?? _getDefaultForType(json['type'] as String),
      keyFormat: json['key_format'] as String?,
      valueFormat: json['value_format'] as String?,
    );
  }

  static dynamic _getDefaultForType(String type) {
    switch (type) {
      case 'string':
        return '';
      case 'int':
        return 0;
      case 'boolean':
        return false;
      case 'array':
        return [];
      case 'object':
        return {};
      default:
        return '';
    }
  }
}
