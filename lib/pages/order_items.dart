import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/order_item.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

class OrderProductItems extends StatefulWidget {
  const OrderProductItems({super.key});

  @override
  State<OrderProductItems> createState() => _OrderProductItemsState();
}

class _OrderProductItemsState extends State<OrderProductItems> {
  List<OrderItem>? orderItem;
  var formkey = GlobalKey<FormState>();

  void getOrderItem() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""

select OPI.*,P.count as productcount,P.name as productName from orderProductItems OPI
Inner JOIN products P
On OPI.orderId=P.id""");

      if (data.isNotEmpty) {
        orderItem ??= [];
        for (var item in data) {
          orderItem?.add(OrderItem.fromJson(item));
        }
      } else {
        orderItem = [];
      }
    } catch (e) {
      orderItem = [];
      print('Error in get Orderitems $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Text('Order Items',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  )),
              for (var orderItem in orderItem ?? [])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: Text(
                        '${orderItem.product.name ?? 'No name'}, ${orderItem.productCount}X'),
                    trailing: Text('${orderItem.orderId}'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
