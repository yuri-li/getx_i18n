import 'package:test/test.dart';

void main() {
  test('test split',(){
    final nameArr = 'a.b.c'.split('.');
    final index = 1;
    print(nameArr.length);
    final name = 'L_${nameArr.sublist(0, index + 1).join("_")}';//L_a_b_c
    print(name);
    print(nameArr.last);
  });
  test('update person',(){
    var person = Person(name: 'peter');
    updatePerson(person);
    print(person.name);
  });
}
void updatePerson(Person person){
  person.name = 'yuri';
}
class Person{
  String name;

  Person({
    this.name,
  });
}