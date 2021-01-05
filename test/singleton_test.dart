import 'package:test/test.dart';

class Singleton {
  static final Singleton _singleton = Singleton._internal();

  factory Singleton() {
    return _singleton;
  }

  Singleton._internal();
}
void main() {
  test('singleton',(){
    var s1 = Singleton();
    var s2 = Singleton();
    print(identical(s1, s2));  // true
    print(s1 == s2);
  });
}