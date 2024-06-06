import 'dart:ffi';

import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/product.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

class ProductOpsPage extends StatefulWidget {
  final Product ? product;
  const ProductOpsPage({ this.product,
  
  
  super.key});

  @override
  State<ProductOpsPage> createState() => _ProductOpsPageState();
}

class _ProductOpsPageState extends State<ProductOpsPage> {
  
  TextEditingController? nameTextEditingController;
  TextEditingController? descriptionTextEditingController;
  TextEditingController? priceTextEditingController;
  TextEditingController? stockTextEditingController;
TextEditingController? imageTextEditingController;
int ?selectedCategoryId;
bool ?isAvailable;
  var formkey = GlobalKey<FormState>();

  @override
  void initState() {
    nameTextEditingController =
        TextEditingController(text: widget.product?.name ?? '');
       descriptionTextEditingController =
        TextEditingController(text: widget.product?.description ?? '');
       priceTextEditingController =
        TextEditingController(text: '${widget.product?.price ?? ''}');
       stockTextEditingController =
        TextEditingController(text: '${widget.product?.stock ?? ''}');
       imageTextEditingController =
        TextEditingController(text: widget.product?.image ?? '');
        selectedCategoryId=widget.product?.categoryId;
        isAvailable=widget.product?.isAvailable; 
        super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add new' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              AppTextFormField(
                labelText: 'Name',
                controller: nameTextEditingController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              AppTextFormField(
                labelText: 'Description',
                controller: descriptionTextEditingController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
           AppTextFormField(
                labelText: 'Image Url',
                controller: imageTextEditingController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Image Url is required';
                  }
                  return null;
                },
              ),


              const SizedBox(
                height: 20,
              ),
              Row(children: [
                Expanded(child: 
                AppTextFormField(
                labelText: 'Price',             
                  keyboardType:TextInputType.number,
                  inputFormatters:[
                    FilteringTextInputFormatter.digitsOnly,
                  ]
                  
                  controller: priceTextEditingController,
                  validator: (value){
                    if (value!.isEmpty){
                      return 'Price is required';
                    }
                    return null;
                  } 
                ),),
        const SizedBox(
          height: 20,
          ),

               Expanded(child: 
                AppTextFormField(
                  labelText: 'stock',
                  keyboardType:TextInputType.number,
                  inputFormatters:[
                    FilteringTextInputFormatter.digitsOnly,
                  ]
                  
                  controller: stockTextEditingController,
                  validator: (value){
                    if (value!.isEmpty){
                      return 'Stock is required';
                    }
                    return null;
                  } 
                ),),


              ],),

              const SizedBox(
                height: 20,
              ),

              CategoriesDropDown (
                selectedValue:selectedCategoryId,
                onChange: (value) {
                  selectedCategoryId= value;
                  setState(() {
                    
                  });
                }
              ),
              const SizedBox(
                height: 20,
              ), 
              Row(children: [
                const Text('is Product Available'),
                const SizedBox(
                  width: 10,
                ),
                Switch (value:isAvailable?? false,
                onChanged :(value ) {
                  setState(() {
                    isAvailable= value;
                  });
                 
                }),
                
              ],),
              const SizedBox(
                height: 20,
              ),


              AppElevatedButton(
                  label: widget.product == null ? 'Submit' : ' Edit',
                  onPressed: () async {
                    await onSubmit();
                  })
            ],
          ),
        ),
      ),
    );
  }
Future<void> onSubmit() async {
    try {
      if (formkey.currentState!.validate()) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        //add C ategory logic
        if (widget.product == null) {
          await sqlHelper.db!.insert(
              'categories',
              conflictAlgorithm: ConflictAlgorithm.replace,
              {
                'name': nameTextEditingController?.text,
                'description': descriptionTextEditingController?.text,
                'price': double .parse(priceTextEditingController?.text??'0.0'),
                'stock':int.parse(stockTextEditingController?.text??'0'),
                'image':imageTextEditingController?.text,
                'categoryId':selectedCategoryId,
                'isAvailabe':isAvailable??false,
                
                
              });
        } else {
          //undate Category logic
          //await sqlHelper.db!.update(
       //       'categories',
              //{
               // 'name': nameTextEditingController?.text,
               // 'description': descriptionTextEditingController?.text,
             // },
             // where: 'id= ?',
              //whereArgs: [widget.product?.id]);
        }

ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.product == null
                ? 'Category added successfully'
                : 'Category updated successfully',
            style: TextStyle(color: Colors.white),
          ),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error:$e',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}

 
 
 
 
 
 
 
 
 
 
 
 
 
 
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}