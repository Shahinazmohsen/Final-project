import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/client.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientDropDown extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChanged;
  const ClientDropDown({this.selectedValue, this.onChanged, super.key});

  @override
  State<ClientDropDown> createState() => _ClientDropDownState();
}

class _ClientDropDownState extends State<ClientDropDown> {
  List<Client>? clients;
  @override
  void initState() {
    getClients();
    super.initState();
  }

  void getClients() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('clients');
      if (data.isNotEmpty) {
        clients ??= [];
        for (var item in data) {
          clients?.add(Client.fromJson(item));
        }
      } else {
        clients = [];
      }
    } catch (e) {
      clients = [];
      print('Error in get Clients $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return clients == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : (clients?.isEmpty ?? false)
            ? Center(
                child: Text('No client found'),
              )
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: DropdownButton(
                            value: widget.selectedValue,
                            isExpanded: true,
                            underline: SizedBox(),
                            hint: Text('Select Client'),
                            items: [
                              for (var client in clients!)
                                DropdownMenuItem(
                                  child: Text(client.name ?? 'No name'),
                                  value: client.id,
                                )
                            ],
                            onChanged: widget.onChanged),
                      ),
                    ),
                  ),
                ],
              );
  }
}
