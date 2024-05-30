import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


void main() async {
WidgetsFlutterBinding.ensureInitialized();


  var sqlHelper= SqlHelper();
  await sqlHelper.initDb();
  if (sqlHelper.db != null) {
  GetIt.I.registerSingleton<SqlHelper>(sqlHelper);} 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'easy pos',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}


    
  

