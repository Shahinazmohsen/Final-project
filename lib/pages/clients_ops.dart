import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/widgets/app_elevated_button.dart';
import 'package:easy_pos/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:easy_pos/models/client.dart';
import 'package:flutter/services.dart';

class ClientsOpsPage extends StatefulWidget {
  final Client? client;
  const ClientsOpsPage({this.client, super.key});

  @override
  State<ClientsOpsPage> createState() => _ClientsOpsState();
}

class _ClientsOpsState extends State<ClientsOpsPage> {
  TextEditingController? nameTextEditingController;
  TextEditingController? emailTextEditingController;
  TextEditingController? phoneTextEditingController;
  TextEditingController? addressTextEditingController;

  var formkey = GlobalKey<FormState>();

  @override
  void initState() {
    nameTextEditingController =
        TextEditingController(text: widget.client?.name ?? '');
    emailTextEditingController =
        TextEditingController(text: widget.client?.email ?? '');
    phoneTextEditingController =
        TextEditingController(text: '${widget.client?.phone ?? ''}');
    addressTextEditingController =
        TextEditingController(text: widget.client?.address ?? '');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Add new' : 'Edit client'),
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter
                ],
                labelText: 'Email',
                controller: emailTextEditingController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              AppTextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                labelText: 'Phone',
                maxLengh: 11,
                controller: phoneTextEditingController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Phone is required';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              AppTextFormField(
                labelText: 'Address',
                controller: addressTextEditingController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              AppElevatedButton(
                  label: widget.client == null ? 'Submit' : ' Edit',
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
        //add Client logic
        if (widget.client == null) {
          await sqlHelper.db!
              .insert('clients', conflictAlgorithm: ConflictAlgorithm.replace, {
            'name': nameTextEditingController?.text,
            'email': emailTextEditingController?.text,
            'phone': int.parse(phoneTextEditingController?.text ?? '0'),
            'address': addressTextEditingController?.text,
          });
        } else {
          //update Client logic
          await sqlHelper.db!.update(
              'clients',
              {
                'name': nameTextEditingController?.text,
                'email': emailTextEditingController?.text,
                'phone': int.parse(phoneTextEditingController?.text ?? '0'),
                'address': addressTextEditingController?.text,
              },
              where: 'id= ?',
              whereArgs: [widget.client?.id]);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            widget.client == null
                ? 'Client added successfully'
                : 'Client updated successfully',
            style: const TextStyle(color: Colors.white),
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
