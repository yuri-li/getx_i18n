import 'package:meta/meta.dart';

import '../Row.dart';
import 'CustomEnum.dart';

class Plain {
  String key;
  KeyType keyType;
  List<String> args;
  CustomEnum customEnum;

  Plain({
    @required this.key,
    @required this.keyType,
    @required this.args,
    @required this.customEnum,
  });

  @override
  // ignore: missing_return
  String toString() {
    if (args == null) {
      return "static String get ${key.split('.').last} => '${key}'.tr;";
    } else {
      var argsMap = _buildArgsMap();
      var methodParams = _buildMethodParams();
      // ignore: missing_enum_constant_in_switch
      switch (keyType) {
        case KeyType.Plural:
        case KeyType.PluralWithArgs:
        case KeyType.NestedPlural:
        case KeyType.NestedPluralWithArgs:
          return _buildPluralWithArgs(argsMap, methodParams);
          break;
        case KeyType.EnumType:
        case KeyType.EnumTypeWithArgs:
        case KeyType.NestedEnumType:
        case KeyType.NestedEnumTypeWithArgs:
          return _buildEnumTypeWithArgs(argsMap, methodParams);
          break;
        case KeyType.Plain:
        case KeyType.PlainWithArgs:
        case KeyType.Nested:
        case KeyType.NestedWithArgs:
          return _buildPlainWithArgs(argsMap, methodParams);
          break;
      }
    }
  }

  String _buildMethodParams() {
    final buffer = StringBuffer();
    args.forEach((element) {
      if (element == 'count') {
        buffer.write('int count,');
      } else if (customEnum != null && customEnum.enumType == '${element[0].toUpperCase()}${element.substring(1)}') {
        buffer.write('${customEnum.enumType} ${element},');
      } else {
        buffer.write(' String ${element},');
      }
    });
    return buffer.toString();
  }

  String _buildArgsMap() {
    final buffer = StringBuffer();
    buffer.write('{\n');
    args.forEach((element) {
      if (element == 'count') {
        buffer.write("              'count': count.toString(),\n");
      } else if(customEnum!=null && customEnum.enumType == '${element[0].toUpperCase()}${element.substring(1)}'){
        buffer.write("              '${element}': ${element}.toString(),\n");
      } else {
        buffer.write("              '${element}': ${element},\n");
      }
    });
    buffer.write('            }');
    return buffer.toString();
  }

  String _buildPluralWithArgs(String argsMap, String methodParams) {
    return """${_buildModifier()}String ${key.split('.').last}(${methodParams}) {
    if (count == 0) {
      return '${key}.Zero'.trMap(${argsMap});
    } else if (count == 1) {
      return '${key}.One'.trMap(${argsMap});
    } else {
      return '${key}.More'.trMap(${argsMap});
    }
  }""";
  }

  String _buildModifier() {
    if ([KeyType.Plural, KeyType.PluralWithArgs, KeyType.EnumType, KeyType.EnumTypeWithArgs, KeyType.Plain, KeyType.PlainWithArgs]
        .contains(keyType)) {
      return 'static ';
    } else {
      return '';
    }
  }

  String _buildEnumTypeWithArgs(String argsMap, String methodParams) {
    return '''${_buildModifier()}String ${key.split('.').last}(${methodParams}) {
${_buildEnumBody(argsMap)}
    }''';
  }

  String _buildEnumBody(String argsMap) {
    final buffer = StringBuffer();
    customEnum.values.forEach((element) {
      buffer.write("""
        if (${args.first} == ${customEnum.enumType}.${element}) {
            return '${key}.${element}'.trMap(${argsMap});
        }
""");
    });
    return buffer.toString();
  }

  String _buildPlainWithArgs(String argsMap, String methodParams) {
    return "${_buildModifier()}String ${key.split('.').last}(${methodParams}) => '${key}'.trMap(${argsMap});";
  }
}
