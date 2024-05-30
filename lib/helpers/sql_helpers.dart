import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper{
  Database? db;
  
  Future <void> createTables() async {
    try {
      await db!.execute(""" create table categories (
        id integer primary key,
        name text,description text)
      """);
      print('create products table');
    } catch(e,s)  {
      print('error in create categories table $e');
      print('syatch trace $s');
    }
  }

  Future <void> initDb() async {
    try {
      if (kIsWeb) {
        var factory= databaseFactoryFfiWeb;
        db = await factory.openDatabase('pos.db');
        print('===========Db created');
      } else {
db = await openDatabase('pos.db',
version: 1,
onCreate: (db, version) => {
  print('===========Db created')
  },
  );
      }
    }catch (e) {
      print('Error in create db:${e}');
    }
  }





    }
  
