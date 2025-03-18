// import 'package:realm/realm.dart';
//
// import 'mongoDb.dart';
//
// Future<List<MyData>> getData() async {
//
//   final appConfig = AppConfiguration('your-realm-app-id');
//   final app = App(appConfig);
//
//   final user = await app.logIn(Credentials.anonymous());
//   final config = Configuration.flexibleSync(user, [MyData.schema]);
//   final realm = Realm(config);
//
//   realm.subscriptions.update((mutableSubscriptions) {
//     mutableSubscriptions.add(realm.all<MyData>());
//   });
//
//   // Fetch existing data
//   var data = realm.all<MyData>().toList();
//   return data;
// }
