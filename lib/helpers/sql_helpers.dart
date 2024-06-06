import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  Database? db;

  Future<bool> createTables() async {
    try {
      var batch = db!.batch();

      batch.execute(""" Create table  If not exists categories (
        id integer primary key,
        name text not null, 
        description text not null)
      """);

      batch.execute(""" Create table  If not exists products (
        id integer primary key,
        name text,description text,
        price double,
        stock integer,
        isAvailable boolean,
        image text,
        categoryId integer,
        foreign key(categoryId) references categories(id)
        ON DELETE RESTRICT)
      """);
      batch.execute(""" Create table  If not exists clients (
        id integer primary key,
        name text,
        email text, 
        phone text,
         address text)
      """);

      var result = await batch.commit();

      print('Tables created successfully: $result');
      return true;
    } catch (e) {
      print('error in create  tables $e');
      return false;
    }
  }

  Future<void> initDb() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        db = await factory.openDatabase('pos.db');
        print('===========Db created');
      } else {
        db = await openDatabase(
          'pos.db',
          version: 1,
          onCreate: (db, version) => {print('===========Db created')},
        );
      }
    } catch (e) {
      print('Error in create db:${e}');
    }
  }
}
