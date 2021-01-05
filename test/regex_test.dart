import 'package:test/test.dart';

void main() {
  test('KeyRegex.NestedPlural', () {
    final regex = RegExp(r'^(([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+)\(Plural\.(zero|one|more)\)$');
    expect(regex.hasMatch('user.contact(Gender.male)'), false);
    expect(regex.hasMatch('contact(Gender.male)'), false);

    expect(regex.hasMatch('item(Plural.zero)'), false);
    expect(regex.hasMatch('item(Plural.any)'), false);

    expect(regex.hasMatch('product.item(Plural.zero)'), true); //3,product.item(Plural.zero),product.item,product.,zero
    expect(regex.hasMatch('product.item(Plural.one)'), true);
    expect(regex.hasMatch('product.item(Plural.more)'), true);

    expect(regex.hasMatch('template.product.item(Plural.zero)'), true);//3,template.product.item(Plural.zero),template.product.item,product.,zero

    showAllMatches(regex, 'product.item(Plural.zero)');
    showAllMatches(regex, 'template.product.item(Plural.zero)');
    showAllMatches(regex, 'a.b.c.d.product.item(Plural.zero)');//3,a.b.c.d.product.item(Plural.zero),a.b.c.d.product.item,product.,zero

  });

  test('KeyRegex.Plural', () {
    final regex = RegExp(r'^([a-zA-Z0-9]+)\(Plural\.(zero|one|more)\)$');
    expect(regex.hasMatch('user.contact(Gender.male)'), false);
    expect(regex.hasMatch('contact(Gender.male)'), false);

    expect(regex.hasMatch('item(Plural.zero)'), true); //2,item(Plural.zero),item,zero
    expect(regex.hasMatch('item(Plural.one)'), true);
    expect(regex.hasMatch('item(Plural.more)'), true);

    expect(regex.hasMatch('item(Plural.any)'), false);

    showAllMatches(regex, 'item(Plural.zero)');
  });

  test('KeyRegex.NestedEnumType', () {
    final regex = RegExp(r'^(([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+)\(([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)\)$');
    expect(regex.hasMatch('user.contact(Gender.male)'), true); //4,user.contact(Gender.male),user.contact,user.,Gender,male
    expect(regex.hasMatch('contact(Gender.male)'), false);

    showAllMatches(regex, 'user.contact(Gender.male)');
    showAllMatches(regex, 'a.b.c.d.contact(Gender.male)');
  });
  test('KeyRegex.EnumType', () {
    final regex = RegExp(r'^([a-zA-Z0-9]+)\(([a-zA-Z0-9]+)\.([a-zA-Z0-9]+)\)$');
    expect(regex.hasMatch('contact(Gender.male)'), true); //3,contact(Gender.male),contact,Gender,male
    expect(regex.hasMatch('date.picker'), false);

    showAllMatches(regex, 'contact(Gender.male)');
  });

  test('KeyRegex.nested', () {
    final regex = RegExp(r'^([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+$');
    expect(regex.hasMatch('hello'), false);
    expect(regex.hasMatch('date.picker'), true); //1,date.picker,date.

    showAllMatches(regex, 'date.picker');
    showAllMatches(regex, 'a.b.c.d.picker');
  });

  test('KeyRegex.plain', () {
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    expect(regex.hasMatch('hello'), true); //0,hello
    expect(regex.hasMatch('hello1'), true); //0,hello1
    expect(regex.hasMatch('hel_lo'), false);
    expect(regex.hasMatch('date.picker'), false);

    showAllMatches(regex, 'hello');
  });

  test('ValueRegex.plain', () {
    final regex = RegExp(r'^.*$');

    expect(regex.hasMatch('This is \na  multiline\nexample.'), false);
    expect(regex.hasMatch('hello!'), true);
    expect(regex.hasMatch('你好！'), true);
    expect(regex.hasMatch('There are {{count}} items'), true);
  });

  test('ValueRegex.multiline', () {
    final regex = RegExp(r'\n');

    expect(regex.hasMatch('This is \na  multiline\nexample.'), true);
    expect(regex.hasMatch('hello!'), false);
    expect(regex.hasMatch('There are {{count}} items'), false);
  });
  test('ValueRegex.args', () {
    final regex = RegExp(r'\{\{([a-zA-Z0-9]+)\}\}');

    expect(regex.hasMatch('This is \na  multiline\nexample.'), false);
    expect(regex.hasMatch('hello!'), false);
    expect(regex.hasMatch('There are {{count}} items'), true); //1,{{count}},count
    expect(regex.hasMatch('There are\n {{count}} items'), true); //1,{{count}},count

    expect(regex.hasMatch('Hi {{firstName}},There are {{count}} items'), true); //1,{{firstName}},firstName;1,{{count}},count

    showAllMatches(regex, 'There are {{count}} items');
    showAllMatches(regex, 'There are\n {{count}} items');
    showAllMatches(regex, 'Hi {{firstName}},There are {{count}} items');
  });
}

void showAllMatches(RegExp regex, String template) {
  var matches = regex.allMatches(template);

  final message = matches.map((match) {
    var buffer = StringBuffer();
    buffer.write('${match.groupCount}');
    for (var i = 0; i <= match.groupCount; i++) {
      buffer.write(',${match.group(i)}');
    }
    return buffer.toString();
  }).join(';');
  print(message);
}
