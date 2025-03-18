// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'mongoDb.dart';
//
// // **************************************************************************
// // RealmObjectGenerator
// // **************************************************************************
//
// // ignore_for_file: type=lint
// class MyData extends _MyData with RealmEntity, RealmObjectBase, RealmObject {
//   MyData(
//     String id,
//     String name,
//     int age,
//   ) {
//     RealmObjectBase.set(this, 'id', id);
//     RealmObjectBase.set(this, 'name', name);
//     RealmObjectBase.set(this, 'age', age);
//   }
//
//   MyData._();
//
//   @override
//   String get id => RealmObjectBase.get<String>(this, 'id') as String;
//   @override
//   set id(String value) => RealmObjectBase.set(this, 'id', value);
//
//   @override
//   String get name => RealmObjectBase.get<String>(this, 'name') as String;
//   @override
//   set name(String value) => RealmObjectBase.set(this, 'name', value);
//
//   @override
//   int get age => RealmObjectBase.get<int>(this, 'age') as int;
//   @override
//   set age(int value) => RealmObjectBase.set(this, 'age', value);
//
//   @override
//   Stream<RealmObjectChanges<MyData>> get changes =>
//       RealmObjectBase.getChanges<MyData>(this);
//
//   @override
//   MyData freeze() => RealmObjectBase.freezeObject<MyData>(this);
//
//   static SchemaObject get schema => _schema ??= _initSchema();
//   static SchemaObject? _schema;
//   static SchemaObject _initSchema() {
//     RealmObjectBase.registerFactory(MyData._);
//     return const SchemaObject(ObjectType.realmObject, MyData, 'MyData', [
//       SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
//       SchemaProperty('name', RealmPropertyType.string),
//       SchemaProperty('age', RealmPropertyType.int),
//     ]);
//   }
// }
