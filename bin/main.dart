import 'dart:io';

import 'model/Header.dart';
import 'model/Sheet.dart';
import 'service/CsvParser.dart';

Future<void> main() async {
  //1. params
  final locales = {
    'en_US': 'English',
    'zh_CN': '简体中文',
  };
  final from = 'bin/i18n.csv';
  final to = '/Users/yuri/workspace/idea/study/flutter_study/lib/config/lang.dart';

  //2. parser
  final sheet = Sheet(locales, await CsvParser(
    path: from,
    header: Header(langList: locales.keys.toList()),
  ).rowList());

  //3. write file
  final file = File(to);
  await file.writeAsString(sheet.toString());
}
