import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:meta/meta.dart';
import '../model/Header.dart';
import '../model/Row.dart';

class CsvParser {
  String path;
  Header header;

  CsvParser({
    @required this.path,
    @required this.header,
  });

  Future<List<Row>> rowList() async {
    final rawRowList = await _rawRowList();
    var list = <Row>[];
    rawRowList.asMap().forEach((i, element) {
      list.add(Row(index: i, values: element));
    });
    return list;
  }

  Future<List<Map<String, String>>> _rawRowList() async {
    var fields = await _toFields();
    //key: column index
    //value: header
    final columnIndexMap = header.columnIndexMap(fields.removeAt(0));
    return fields.map((row){
      var map = <String,String>{};
      row.asMap().forEach((i, element) {
        if(columnIndexMap.containsKey(i)){
          map[columnIndexMap[i]] = element;
        }
      });
      return map;
    }).toList();
  }

  Future<List<List<String>>> _toFields() async {
    final input = File(path).openRead();
    return await input
        .transform(utf8.decoder)
        .transform(CsvToListConverter(shouldParseNumbers: false))
        .map((list) => list.map((e) => e as String).toList())
        .toList();
  }
}
