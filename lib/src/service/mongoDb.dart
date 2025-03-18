// // // Method 1: Using the MongoDB Realm SDK (now MongoDB Atlas Device SDK)
// //
// // // Step 1: Add the MongoDB Realm dependencies to your pubspec.yaml
// // // dependencies:
// // //   flutter:
// // //     sdk: flutter
// // //   realm: ^1.0.0
// //
// // // Step 2: Initialize Realm in your app
// // import 'package:realm/realm.dart';
// //
// // void initializeRealm() async {
// //   final appId = 'your-realm-app-id'; // Get this from MongoDB Atlas
// //   final app = App(AppConfiguration(appId));
// //
// //   try {
// //     // Anonymous login (you can also use email/password, OAuth, etc.)
// //     final user = await app.logIn(Credentials.anonymous());
// //     print('Successfully logged in: ${user.id}');
// //
// //     // Now you can access your MongoDB collections
// //     final mongodb = user.mongoClient('mongodb-atlas');
// //     final collection = mongodb.db('your-database').collection('your-collection');
// //
// //     // Ready to perform operations
// //   } catch (e) {
// //     print('Error logging in: $e');
// //   }
// // }
// //
// // // Step 3: Define your CRUD operations
// // class MongoDBService {
// //   late User user;
// //   late MongoCollection collection;
// //
// //   Future<void> initialize() async {
// //     final app = App(AppConfiguration('your-realm-app-id'));
// //     user = await app.logIn(Credentials.anonymous());
// //     collection = user.mongoClient('mongodb-atlas')
// //         .db('your-database')
// //         .collection('your-collection');
// //   }
// //
// //   // Create
// //   Future<Document> insertDocument(Map<String, dynamic> data) async {
// //     final result = await collection.insertOne(data);
// //     return result.insertedId;
// //   }
// //
// //   // Read
// //   Future<List<Document>> getDocuments({Map<String, dynamic>? filter}) async {
// //     final documents = await collection.find(
// //       filter: filter ?? {},
// //     );
// //     return documents;
// //   }
// //
// //   // Update
// //   Future<int> updateDocument(Map<String, dynamic> filter, Map<String, dynamic> update) async {
// //     final result = await collection.updateOne(
// //       filter: filter,
// //       update: {'\$set': update},
// //     );
// //     return result.modifiedCount;
// //   }
// //
// //   // Delete
// //   Future<int> deleteDocument(Map<String, dynamic> filter) async {
// //     final result = await collection.deleteOne(filter);
// //     return result.deletedCount;
// //   }
// // }
// //
// // // import 'dart:developer';
// // //
// // // import 'package:haivazoho/constants.dart';
// // // import 'package:mongo_dart/mongo_dart.dart';
// // //
// // // class Mongodb {
// // //   static var db, userCollection;
// // //   static connect() async{
// // //     db = await Db.create(mongoUrl);
// // //     await db.open();
// // //     inspect(db);
// // //     userCollection = db.collection(myCollection);
// // //   }
// // // }
//
// import 'package:realm/realm.dart';
//
// part 'mongoDb.g.dart';
//
// @RealmModel()
// class _MyData {
//   @PrimaryKey()
//   late String id;
//   late String name;
//   late int age;
// }
