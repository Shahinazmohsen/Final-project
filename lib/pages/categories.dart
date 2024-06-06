import 'dart:js_util';

import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/category.dart';
import 'package:easy_pos/pages/categories_ops.dart';
import 'package:easy_pos/widgets/app_table.dart';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category>? categories;
  @override
  void initState() {
    getCategories();
    super.initState();
  }

  void getCategories() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      var data = await sqlHelper.db!.query('categories');
      if (data.isNotEmpty) {
        categories ??= [];
        for (var item in data) {
          categories?.add(Category.fromJson(item));
        }
      } else {
        categories = [];
      }
    } catch (e) {
      categories = [];
      print('Error in get Categories $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              var result = await Navigator.push(context,
                  MaterialPageRoute(builder: (ctx) => CategoriesOpsPage()));
              if (result ?? false) {
                getCategories();
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
                  getCategories();
                  return;
                }

                var sqlHelper = await GetIt.I.get<SqlHelper>();
                var data = await sqlHelper.db!.rawQuery(
                    """ select * from categories where name like '%$text%' OR  description like '%$text%'
                        """);
                if (data.isNotEmpty) {
                  categories = [];
                  for (var item in data) {
                    categories?.add(Category.fromJson(item));
                  }
                } else {
                  categories = [];
                }

                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(),
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
                columns: [
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Center(child: Text('Actions'))),
                ],
                source: CategoriesDataSource(
                    categories: categories,
                    onUpdate: (category) async {
                      var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => CategoriesOpsPage(
                                    category: category,
                                  )));
                      if (result ?? false) {
                        getCategories();
                      }
                    },
                    onDelete: (category) async {
                      await onDeleteCategory(category);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDeleteCategory(Category category) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete category'),
              content:
                  const Text('Are you sure you want to delete this category?'),
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
            .delete('categories', where: 'id=?', whereArgs: [category.id]);
        getCategories();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error in deleting category ${category.name}')));
    }
  }
}

class CategoriesDataSource extends DataTableSource {
  List<Category>? categories;

  void Function(Category)? onUpdate;
  void Function(Category)? onDelete;
  CategoriesDataSource(
      {required this.categories,
      required this.onUpdate,
      required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${categories?[index].id}')),
      DataCell(Text('${categories?[index].name}')),
      DataCell(Text('${categories?[index].description}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onUpdate!(categories![index]);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              onDelete!(categories![index]);
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
  int get rowCount => categories?.length ?? 0;
  @override
  int get selectedRowCount => 0;
}
