import 'package:meta/meta.dart';

import 'Row.dart';
import 'group/CustomClass.dart';
import 'group/CustomEnum.dart';
import 'group/Plain.dart';
import 'group/lang/LangKeys.dart';

class Sheet {
  Map<String, String> locales;
  List<Row> rowList;

  List<LangKeys> keys;
  List<CustomEnum> customEnumList;
  List<Plain> plainList;
  String rootCustomClass;
  String customClass;

  List<CustomClass> _customClassList;
  Map<String, CustomClass> _customClassMap;

  Sheet(this.locales, this.rowList) {
    //L.keys
    keys = _buildKeys();
    customEnumList = _buildCustomEnumList();
    plainList = _buildPlainList();
    _customClassList = _buildCustomClassList();
    _customClassList.forEach((element) {
      element.buildChildren(element);
    });
    _customClassMap = <String, CustomClass>{};
    _buildCustomClassMap(_customClassList);
    _customClassMap.removeWhere((key, value) => !value.isRoot);
    rootCustomClass = _buildRootCustomClass();
    _buildCustomClass(_customClassMap.values.toList());
    customClass = _buffer.toString();
  }

  List<LangKeys> _buildKeys() {
    var list = <LangKeys>[];
    for (var lang in locales.keys) {
      var langKeys = LangKeys(lang, <LangValue>[]);
      for (var row in rowList) {
        var langValue = LangValue(row.key, row.values[lang], row.valueType);
        langKeys.valueList.add(langValue);
      }
      list.add(langKeys);
    }
    return list;
  }

  List<CustomEnum> _buildCustomEnumList() {
    var list = <CustomEnum>[];
    for (var row in rowList) {
      if (row.enumType != null) {
        var customEnumIterable = list.where((element) => element.enumType == row.enumType);
        if (customEnumIterable.isNotEmpty) {
          var customEnum = customEnumIterable.first;
          list.remove(customEnum);
          customEnum.values.add(_enumValue(row.key));
          list.add(customEnum);
        } else {
          list.add(CustomEnum(row.enumType, <String>[_enumValue(row.key)]));
        }
      }
    }
    return list;
  }

  List<Plain> _buildPlainList() {
    var list = <Plain>[];
    for (var row in rowList) {
      if ([
        KeyType.Plain,
        KeyType.PlainWithArgs,
        KeyType.Plural,
        KeyType.PluralWithArgs,
        KeyType.EnumType,
        KeyType.EnumTypeWithArgs,
      ].contains(row.keyType)) {
        var key = row.key;
        if ([KeyType.Plural, KeyType.PluralWithArgs, KeyType.EnumType, KeyType.EnumTypeWithArgs].contains(row.keyType)) {
          key = key.substring(0, key.lastIndexOf('.'));
        }
        var customEnum;
        if ([KeyType.EnumType, KeyType.EnumTypeWithArgs].contains(row.keyType)) {
          customEnum = customEnumList.where((element) => element.enumType == row.enumType).first;
        }
        final plainIterable = list.where((element) => element.key == key);
        if (plainIterable.isNotEmpty) {
          final plain = plainIterable.first;
          list.remove(plain);
          row.args.forEach((arg) {
            if (!plain.args.contains(arg)) {
              plain.args.add(arg);
            }
          });
          list.add(plain);
        } else {
          list.add(Plain(key: key, keyType: row.keyType, args: row.args, customEnum: customEnum));
        }
      }
    }
    return list;
  }

  List<CustomClass> _buildCustomClassList() {
    var list = <CustomClass>[];
    for (var row in rowList) {
      if ([
        KeyType.Nested,
        KeyType.NestedWithArgs,
        KeyType.NestedPlural,
        KeyType.NestedPluralWithArgs,
        KeyType.NestedEnumType,
        KeyType.NestedEnumTypeWithArgs,
      ].contains(row.keyType)) {
        var key = row.key;
        if ([KeyType.NestedPlural, KeyType.NestedPluralWithArgs, KeyType.NestedEnumType, KeyType.NestedEnumTypeWithArgs].contains(row.keyType)) {
          key = key.substring(0, key.lastIndexOf('.'));
        }
        var customEnum;
        if ([KeyType.NestedEnumType, KeyType.NestedEnumTypeWithArgs].contains(row.keyType)) {
          customEnum = customEnumList.where((element) => element.enumType == row.enumType).first;
        }
        final iterable = list.where((element) => element.key == key);
        if (iterable.isNotEmpty) {
          var temp = iterable.first;
          list.remove(temp);
          row.args.forEach((arg) {
            if (!temp.args.contains(arg)) {
              temp.args.add(arg);
            }
          });
          list.add(temp);
        } else {
          list.add(CustomClass(
              key: key, name: 'L_${key.split(".")[0]}', index: 0, isRoot: true, keyType: row.keyType, args: row.args, customEnum: customEnum));
        }
      }
    }
    return list;
  }

  String _enumValue(String key) => key.substring(key.lastIndexOf('.') + 1);

  void _buildCustomClassMap(List<CustomClass> list) {
    list?.forEach((element) {
      if (_customClassMap.containsKey(element.name)) {
        var old = _customClassMap[element.name];
        _customClassMap.remove(element.name);
        if (element.plainList != null) {
          if (old.plainList == null) {
            old.plainList = element.plainList;
          } else {
            old.plainList.addAll(element.plainList);
          }
        }

        if (element.customClassList != null) {
          _buildCustomClassMap(element.customClassList);
          if (old.customClassList == null) {
            old.customClassList = element.customClassList;
          } else {
            old.customClassList.addAll(element.customClassList);
          }
        }
        _customClassMap[element.name] = old;
      } else {
        _buildCustomClassMap(element.customClassList);
        _customClassMap[element.name] = element;
      }
    });
  }

  String _buildRootCustomClass() => _customClassMap.values.join('\n');

  final _buffer = StringBuffer();
  void _buildCustomClass(List<CustomClass> list) {
    if (list != null) {
      list.forEach((value) {
        _buffer.write('''
class ${value.name}{
    static final ${value.name} _singleton = ${value.name}._internal();
    factory ${value.name}() {
      return _singleton;
    }
    ${value.name}._internal();
    ${_buildPlain(value.plainList, value.isRoot)}
    ${_buildChildrenCustomClass(value.customClassList)}
}
''');
        if (value.customClassList != null) {
          _buildCustomClass(value.customClassList);
        }
      });
    }
  }

  String _buildPlain(List<Plain> list, bool isRoot) {
    if (list != null) {
      if (isRoot) {
        return list.map((e) => e.toString().replaceAll('static ', '')).join('\n');
      } else {
        return list.join('\n');
      }
    } else {
      return '';
    }
  }

  String _buildChildrenCustomClass(List<CustomClass> customClassList) {
    if (customClassList != null) {
      return customClassList.join('\n');
    } else {
      return '';
    }
  }

  String _buildLocales() {
    final buffer = StringBuffer();
    buffer.write('  static final locales = {\n');
    // 'en_US': 'English',
    // 'zh_CN': '简体中文',
    locales.forEach((key, value) {
      buffer.write("    '${key}': '${value}',\n");
    });
    buffer.write('  };\n');
    buffer.write("  static final defaultLocale = Locale('en', 'US');\n");
    buffer.write("  static final fallbackLocale = Locale('en', 'US');\n");
    return buffer.toString();
  }

  String _buildKeysStr() {
    final buffer = StringBuffer();
    buffer.write('\n  @override\n');
    buffer.write('  Map<String, Map<String, String>> get keys => {\n');
    buffer.write(keys.join(',\n'));
    buffer.write('\n');
    buffer.write('  };');
    return buffer.toString();
  }

  @override
  String toString() {
    return """
import 'dart:ui';

import 'package:get/get.dart';

class L extends Translations {
${_buildLocales()}
${_buildKeysStr()}
${plainList.join('\n')}
${rootCustomClass}
}

${customClass}
${customEnumList.join('\n')}
extension CustomTrans on String {
  String trMap(Map<String, String> map) {
    var text = tr;
    map.forEach((key, value) {
      if(value != null) {
        text = text.replaceAll('{{\${key}}}', value);
      }
    });
    return text;
  }
}
""";
  }
}
