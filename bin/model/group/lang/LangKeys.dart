import '../../Row.dart';

class LangKeys{
  String lang;
  List<LangValue> valueList;

  LangKeys(this.lang, this.valueList);

  @override
  String toString() {
    return """  '${lang}': {
${valueList.join(',\n')}
    }""";
  }
}
class LangValue{
  String key;
  String value;
  ValueType valueType;

  LangValue(this.key, this.value, this.valueType);

  @override
  String toString() {
    if(valueType == ValueType.Multiline){
      return """    '${key}': '''${value}'''""";
    }else{
      return """    '${key}': '${value}'""";
    }
  }
}