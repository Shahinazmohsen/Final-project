import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/product.dart';
import 'package:easy_pos/pages/products_ops.dart';
import 'package:easy_pos/widgets/app_table.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:data_table_2/data_table_2.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product>? products;
  @override
  void initState() {
    getProducts();
    super.initState();
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.rawQuery("""

select P.*,C.name as categoryName,C.description as categoryDescription from products P
Inner JOIN categories C
On P.categoryId=C.id""");

      if (data.isNotEmpty) {
        products ??= [];
        for (var item in data) {
          products?.add(Product.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      products = [];
      print('Error in get Products $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => ProductOpsPage()));
              if (result ?? false) {
                getProducts();
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
                  getProducts();
                  return;
                }

                var sqlHelper = await GetIt.I.get<SqlHelper>();
                var data = await sqlHelper.db!.rawQuery(
                    """ select * from products where name like '%$text%' OR  description like '%$text%'
                   """);
                if (data.isNotEmpty) {
                  products = [];
                  for (var item in data) {
                    products?.add(Product.fromJson(item));
                  }
                } else {
                  products = [];
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
                minWidth: 1100,
                columns: const [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Stock')),
                  DataColumn(label: Text('isAvailable')),
                  DataColumn(label: Center(child: Text('Image'))),
                  DataColumn(label: Text('CAT Name')),
                  DataColumn(label: Text('CAT Description')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: ProductsDataSource(
                    products: products,
                    onUpdate: (product) async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) =>
                                  ProductOpsPage(product: product)));

                      if (result ?? false) {
                        getProducts();
                      }
                    },
                    onDelete: (product) async {
                      await onDeleteProduct(product);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteProduct(Product product) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Product'),
              content:
                  const Text('Are you sure you want to delete this product?'),
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
            .delete('product', where: 'id=?', whereArgs: [product.id]);
        getProducts();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error in deleting product ${product.name}')));
    }
  }
}

class ProductsDataSource extends DataTableSource {
  List<Product>? products;

  void Function(Product)? onUpdate;
  void Function(Product)? onDelete;
  ProductsDataSource(
      {required this.products, required this.onUpdate, required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${products?[index].id}')),
      DataCell(Text('${products?[index].name}')),
      DataCell(Text('${products?[index].description}')),
      DataCell(Text('${products?[index].price}')),
      DataCell(Text('${products?[index].stock}')),
      DataCell(Text('${products?[index].isAvailable}')),
      DataCell(Center(
        child: Image.network(products?[index].image ?? ''),
      )),
      DataCell(Text('${products?[index].categoryName}')),
      DataCell(Text('${products?[index].categoryDescription}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              onUpdate!(products![index]);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              onDelete!(products![index]);
            },
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => products?.length ?? 0;
  @override
  int get selectedRowCount => 0;
}
