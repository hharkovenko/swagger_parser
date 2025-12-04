import 'package:swagger_parser/src/parser/model/normalized_identifier.dart';
import 'package:swagger_parser/swagger_parser.dart';

/// Generate global functions for a given data class to allow serialization and deserialization using compute()
String dartComputeDtoTemplate(
  UniversalDataClass dataClass,
) {
  final sb = StringBuffer()
    ..write('\n')
    ..write(_generateDescription())
    ..write('\n')
    ..write(_generateForClass(dataClass))
    ..write('\n')
    ..write(_generateForList(dataClass));
  return sb.toString();
}

String _generateDescription() {
  return '''
///Generated mapping functions for compute() serialization and deserialization.
''';
}

String _generateForClass(UniversalDataClass dataClass) {
  final name = dataClass.name.toPascal;

  return '''
Map<String, dynamic> serialize$name($name object) => object.toJson();
$name deserialize$name(Map<String, dynamic> json) => $name.fromJson(json);
''';
}

String _generateForList(UniversalDataClass dataClass) {
  final name = dataClass.name.toPascal;
  return '''
List<Map<String, dynamic>> serialize${name}List(List<$name> objects) => objects.map((e) => e.toJson()).toList();
List<$name> deserialize${name}List(List<Map<String, dynamic>> json) => json.map((e) => $name.fromJson(e)).toList();
''';
}
