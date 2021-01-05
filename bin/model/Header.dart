import 'package:meta/meta.dart';

class Header {
  String key;
  List<String> langList;
  // key: column index
  // value: header name
  // Map<int, String> headerColumnIndexMap;
  Map<int, String> columnIndexMap(List<String> headerFields) {
    var map = <int, String>{};
    headerFields.asMap().forEach((i, element) {
      if (element == key || langList.contains(element)) {
        map[i] = element;
      }
    });
    return map;
  }

  Header({
    @required this.langList,
  }){
    key = 'Key';
  }

  @override
  String toString() {
    return 'Header{key: $key, langList: $langList}';
  }
}
