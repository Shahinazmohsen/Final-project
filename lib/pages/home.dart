

import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool showloading =true;
  bool result=false;
  @override

   void initState()  {
  init();
  super .initState();}

  void init() async {
     result = await GetIt.I.get<SqlHelper>().createTables(); 
    showloading= false;
    setState(() {
      
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar:AppBar(title:Text('easy_pos'),),
        
      body: Row(
        children: [
          Text( 'Tables creation'),  Padding( 
            padding: const EdgeInsets.symmetric(horizontal: 10),


            child: showloading ?

              Transform.scale(
              scale: .5,
               child: CircularProgressIndicator(
                color: Colors.black,

            )
             
              ):

            
             CircleAvatar(radius: 10,
             
              backgroundColor:
              result ?
               Colors.green:
               Colors.red,

             
            ),
             
           
            ),
          ]),
      
      floatingActionButton: FloatingActionButton(onPressed: () async{
        var sqlHelper = GetIt.I.get<SqlHelper>();


        sqlHelper.createTables();
      },)

    ); 
  }
}
