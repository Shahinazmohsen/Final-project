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
  TextEditingController? nameTextEditingController;
  TextEditingController? descriptionTextEditingController;
  var formkey = GlobalKey<FormState>();

  @override
  void initState() {
    nameTextEditingController =
        TextEditingController(text: widget.category?.name ?? '');
    descriptionTextEditingController =
        TextEditingController(text: widget.category?.description ?? '');

    super.initState();
  }

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
        //add C ategory logic
        if (widget.category == null) {
          await sqlHelper.db!.insert(
              'categories',
              conflictAlgorithm: ConflictAlgorithm.replace,
              {
                'name': nameTextEditingController?.text,
                'description': descriptionTextEditingController?.text,
              });
        } else {
          //undate Category logic
          await sqlHelper.db!.update(
              'categories',
              {
                'name': nameTextEditingController?.text,
                'description': descriptionTextEditingController?.text,
              },
              where: 'id= ?',
              whereArgs: [widget.category?.id]);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.category == null
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
