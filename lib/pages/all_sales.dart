import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/order.dart';
import 'package:easy_pos/models/order_item.dart';
import 'package:easy_pos/pages/order_items.dart';
import 'package:easy_pos/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllSalesPage extends StatefulWidget {
  const AllSalesPage({super.key});

  @override
  State<AllSalesPage> createState() => _AllSalesPageState();
}

class _AllSalesPageState extends State<AllSalesPage> {
  List<Order>? orders;
  List<OrderItem>? orderItem;
  @override
  void initState() {
    getOrders();

    super.initState();
  }

  void getOrders() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""

select O.*,C.name as clientName,C.Phone as clientPhone from orders O
Inner JOIN clients C
On O.clientId=C.id""");

      if (data.isNotEmpty) {
        orders ??= [];
        for (var item in data) {
          orders?.add(Order.fromJson(item));
        }
      } else {
        orders = [];
      }
    } catch (e) {
      orders = [];
      print('Error in get Orders $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Sales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AppTable(
          minWidth: 800,
          columns: const [
            DataColumn(label: Text('Id')),
            DataColumn(label: Text('Label')),
            DataColumn(label: Text('Total Price')),
            DataColumn(label: Text('Discount')),
            DataColumn(label: Text('Client Name')),
            DataColumn(label: Text('Client Phone')),
            DataColumn(label: Center(child: Text('Actions'))),
          ],
          source: OrdersDataSource(
              orders: orders,
              onShow: (orders) async {
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => OrderProductItems()));
              },
              onDelete: (orders) async {
                await onDelete(orders);
              }),
        ),
      ),
    );
  }

  Future<void> onDelete(Order orders) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Order'),
              content:
                  const Text('Are you sure you want to delete this Order?'),
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
            .delete('Orders', where: 'id=?', whereArgs: [orders.id]);
        getOrders();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error in deleting order ${orders.id}')));
    }
  }
}

class OrdersDataSource extends DataTableSource {
  List<Order>? orders;

  void Function(Order)? onShow;
  void Function(Order)? onDelete;
  OrdersDataSource(
      {required this.orders, required this.onShow, required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${orders?[index].id}')),
      DataCell(Text('${orders?[index].label}')),
      DataCell(Text('${orders?[index].totalPrice}')),
      DataCell(Text('${orders?[index].discount}')),
      DataCell(Text('${orders?[index].clientName}')),
      DataCell(Text('${orders?[index].clientPhone}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              onShow!(
                orders![index],
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              onDelete!(orders![index]);
            },
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => orders?.length ?? 0;
  @override
  int get selectedRowCount => 0;
}
