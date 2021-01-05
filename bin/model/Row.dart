import 'package:meta/meta.dart';

///不包含表头。index=0,对应csv的第2行
class Row {
  int index;
  Map<String, String> values;
  KeyType keyType;
  ValueType valueType;
  String key;
  List<String> args;
  String enumType;

  Row({
    @required this.index,
    @required this.values,
  }) {
    args = <String>[];
    _parseKey();
    _parseValue();
    if (args.isEmpty) {
      args = null;
    }
  }
  void _parseKey() {
    final value = values['Key'];
    if (KeyRegex.nestedPlural.hasMatch(value)) {
      return _parseNestedPlural(value);
    }
    if (KeyRegex.plural.hasMatch(value)) {
      return _parsePlural(value);
    }
    if (KeyRegex.nestedEnumType.hasMatch(value)) {
      return _parseNestedEnumType(value);
    }
    if (KeyRegex.enumType.hasMatch(value)) {
      return _parseEnumType(value);
    }
    if (KeyRegex.nested.hasMatch(value)) {
      return _parseNested(value);
    }
    if (KeyRegex.plain.hasMatch(value)) {
      return _parsePlain(value);
    }
  }

  void _parseNestedPlural(String value) {
    var matches = KeyRegex.nestedPlural.allMatches(value);
    matches.forEach((match) {
      assert(match.groupCount == 3);
      keyType = KeyType.NestedPlural;
      _parsePluralKey(match, 3);
    });
  }

  void _parsePlural(String value) {
    var matches = KeyRegex.plural.allMatches(value);
    matches.forEach((match) {
      assert(match.groupCount == 2);
      keyType = KeyType.Plural;
      _parsePluralKey(match, 2);
    });
  }

  void _parsePluralKey(RegExpMatch match, int groupCount) {
    key = '${match.group(1)}.${match.group(groupCount)}';
    args.add('count');
  }

  void _parseNestedEnumType(String value) {
    var matches = KeyRegex.nestedEnumType.allMatches(value);
    matches.forEach((match) {
      assert(match.groupCount == 4);
      keyType = KeyType.NestedEnumType;
      _parseEnumKey(match, 4);
    });
  }

  void _parseEnumType(String value) {
    var matches = KeyRegex.enumType.allMatches(value);
    matches.forEach((match) {
      assert(match.groupCount == 3);
      keyType = KeyType.EnumType;
      _parseEnumKey(match, 3);
    });
  }

  void _parseEnumKey(RegExpMatch match, int groupCount) {
    key = '${match.group(1)}.${match.group(groupCount)}';

    enumType = match.group(groupCount - 1);
    args.add('${enumType[0].toLowerCase()}${enumType.substring(1)}');
  }

  void _parseNested(String value) {
    var matches = KeyRegex.nested.allMatches(value);
    matches.forEach((match) {
      assert(match.groupCount == 1);
      keyType = KeyType.Nested;
      key = match.group(0);
    });
  }

  void _parsePlain(String value) {
    var matches = KeyRegex.plain.allMatches(value);
    matches.forEach((match) {
      assert(match.groupCount == 0);
      keyType = KeyType.Plain;
      key = match.group(0);
    });
  }

  void _parseValue() {
    final items = _langValueList();
    items.asMap().forEach((i, value) {
      if (i == 0) {
        _parseFirstLangValue(value);
      } else {
        _updateValueArgs(value);
      }
    });
  }

  void _parseFirstLangValue(String value) {
    if (ValueRegex.multiline.hasMatch(value)) {
      valueType = ValueType.Multiline;
    } else {
      valueType = ValueType.Plain;
    }

    _updateValueArgs(value);
  }

  void _updateValueArgs(String value) {
    if (ValueRegex.args.hasMatch(value)) {
      _updateKeyType();
      _parseValueArgs(value);
    }
  }

  void _updateKeyType() {
    // ignore: missing_enum_constant_in_switch
    switch (keyType) {
      case KeyType.Plain:
        keyType = KeyType.PlainWithArgs;
        break;
      case KeyType.Nested:
        keyType = KeyType.NestedWithArgs;
        break;
      case KeyType.Plural:
        keyType = KeyType.PluralWithArgs;
        break;
      case KeyType.NestedPlural:
        keyType = KeyType.NestedPluralWithArgs;
        break;
      case KeyType.EnumType:
        keyType = KeyType.EnumTypeWithArgs;
        break;
      case KeyType.NestedEnumType:
        keyType = KeyType.NestedEnumTypeWithArgs;
        break;
    }
  }

  void _parseValueArgs(String value) {
    var matches = ValueRegex.args.allMatches(value);
    matches.forEach((match) {
      assert(match.groupCount == 1);
      if (!args.contains(match.group(1))) {
        args.add(match.group(1));
      }
    });
  }

  List<String> _langValueList() {
    final tempValues = <String>[];
    values.forEach((key, value) {
      if (key != 'Key') {
        if (value != null && value.isNotEmpty) {
          tempValues.add(value);
        } else {
          throw 'i18n message cannot be empty. rowIndex: ${index + 1}, lang: ${key}';
        }
      }
    });
    return tempValues;
  }

  @override
  String toString() {
    return 'Row{index: $index, values: $values, keyType: $keyType, valueType: $valueType, key: $key, args: $args, enumType: $enumType}';
  }
}

enum KeyType {
  Plain,
  PlainWithArgs,
  Nested,
  NestedWithArgs,

  Plural,
  PluralWithArgs,
  NestedPlural,
  NestedPluralWithArgs,

  EnumType,
  EnumTypeWithArgs,
  NestedEnumType,
  NestedEnumTypeWithArgs
}
enum ValueType { Plain, Multiline }

//按顺序解析
class KeyRegex {
  static final nestedPlural = RegExp(r'^(([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+)\(Plural\.(Zero|One|More)\)$');
  static final plural = RegExp(r'^([a-zA-Z0-9]+)\(Plural\.(Zero|One|More)\)$');

  static final nestedEnumType = RegExp(r'^(([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+)\(([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)\)$');
  static final enumType = RegExp(r'^([a-zA-Z0-9]+)\(([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)\)$');

  static final nested = RegExp(r'^([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+$');
  static final plain = RegExp(r'^[a-zA-Z0-9]+$');
}

class ValueRegex {
  static final multiline = RegExp(r'\n');
  static final args = RegExp(r'\{\{([a-zA-Z0-9]+)\}\}');
}
