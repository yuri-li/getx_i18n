class CustomEnum {
  String enumType;
  List<String> values;

  CustomEnum(this.enumType, this.values);

  @override
  String toString() {
    return 'enum ${enumType} { ${values.join(", ")} }';
  }
}