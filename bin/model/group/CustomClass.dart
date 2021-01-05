import 'package:meta/meta.dart';

import '../Row.dart';
import 'CustomEnum.dart';
import 'Plain.dart';

class CustomClass{
  String key;
  String name;
  int index;
  bool isRoot;
  List<CustomClass> customClassList;
  List<Plain> plainList;
  KeyType keyType;
  List<String> args;
  CustomEnum customEnum;

  CustomClass({
    @required this.key,
    @required this.name,
    @required this.index,
    @required this.isRoot,
    @required this.keyType,
    @required this.args,
    @required this.customEnum,
  });

  void buildChildren(CustomClass parent){
    final arr = key.split('.');
    if(parent.index <= arr.length - 2){//需要构建children
      if(parent.index == arr.length - 2){//最后一级
        if(parent.index != 0){
          parent.isRoot = false;
        }
        parent.plainList = [Plain(key: parent.key,keyType: parent.keyType,args: parent.args, customEnum: parent.customEnum)];
      }else{
        final children = copyWith(
            index: parent.index + 1,
            name: '${name}_${arr[parent.index + 1]}',
            isRoot: false,
        );
        buildChildren(children);
        parent.customClassList = [children];
      }
    }
  }

  @override
  String toString() {
    if(isRoot){
      return 'static ${name} get ${key.split('.')[index]} => ${name}();';
    }else if(index == key.split('.').length - 1){
      return plainList.join('\n');
    }else {
      return '${name} get ${key.split('.')[index]} => ${name}();';
    }
  }

  CustomClass copyWith({
    String key,
    String name,
    int index,
    bool isRoot,
    List<CustomClass> customClassList,
    List<Plain> plainList,
    KeyType keyType,
    List<String> args,
    CustomEnum customEnum,
  }) {
    return CustomClass(
      key: key ?? this.key,
      name: name ?? this.name,
      index: index ?? this.index,
      isRoot: isRoot ?? this.isRoot,
      keyType: keyType ?? this.keyType,
      args: args ?? this.args,
      customEnum: customEnum ?? this.customEnum,
    );
  }
}