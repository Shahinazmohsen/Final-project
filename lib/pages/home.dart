import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      floatingActionButton: FloatingActionButton(onPressed: () async{
        var sqlHelper = GetIt.I.get<SqlHelper>();
        sqlHelper.createTables();
      },)

    ); 
  }
}
