import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/client.dart';
import 'package:easy_pos/pages/clients_ops.dart';
import 'package:easy_pos/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => const ClientsOpsPage()));
              if (result ?? false) {
                getClients();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              onChanged: (text) async {
                if (text == '') {
                  getClients();
                  return;
                }

                var sqlHelper = await GetIt.I.get<SqlHelper>();
                var data = await sqlHelper.db!.rawQuery(
                    """ select * from clients where name like '%$text%' OR  email like '%$text%'
                   """);
                if (data.isNotEmpty) {
                  clients = [];
                  for (var item in data) {
                    clients?.add(Client.fromJson(item));
                  }
                } else {
                  clients = [];
                }

                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                labelText: 'Search',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: AppTable(
                columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Address')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: ClientsDataSource(
                    clients: clients,
                    onUpdate: (client) async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) =>
                                  ClientsOpsPage(client: client)));
                      if (result ?? false) {
                        getClients();
                      }
                    },
                    onDelete: (client) async {
                      await onDeleteClient(client);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteClient(Client client) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete client'),
              content:
                  const Text('Are you sure you want to delete this client?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                )
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        await sqlHelper.db!
            .delete('clients', where: 'id=?', whereArgs: [client.id]);
        getClients();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error in deleting client ${client.name}')));
    }
  }
}

class ClientsDataSource extends DataTableSource {
  List<Client>? clients;

  void Function(Client)? onUpdate;
  void Function(Client)? onDelete;
  ClientsDataSource(
      {required this.clients, required this.onUpdate, required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${clients?[index].id}')),
      DataCell(Text('${clients?[index].name}')),
      DataCell(Text('${clients?[index].email}')),
      DataCell(Text('${clients?[index].phone}')),
      DataCell(Text('${clients?[index].address}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate!(clients![index]);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              onDelete!(clients![index]);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => clients?.length ?? 0;
  @override
  int get selectedRowCount => 0;
}
