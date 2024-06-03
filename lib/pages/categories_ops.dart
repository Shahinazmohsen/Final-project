import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/category.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

class CategoriesOpsPage extends StatefulWidget {
  final Category? category;
  const CategoriesOpsPage({this.category, super.key});

  @override
  State<CategoriesOpsPage> createState() => _CategoriesOpsState();
}

class _CategoriesOpsState extends State<CategoriesOpsPage> {
  var nameTextEditingController = TextEditingController();
  var descriptionTextEditingController = TextEditingController();
  var formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add new' : 'Edit category'),
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
              const SizedBox(
                height: 20,
              ),
              AppElevatedButton(
                  label: widget.category == null ? 'Submit' : ' Edit',
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

        //TODO add update logic
        await sqlHelper.db!.insert(
            'categories',
            conflictAlgorithm: ConflictAlgorithm.replace,
            {
              'name': nameTextEditingController.text,
              'description': descriptionTextEditingController.text,
            });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Category added successfully',
            style: TextStyle(color: Colors.white),
          ),
        ));
        Navigator.pop(context);
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
