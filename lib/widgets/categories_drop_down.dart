import 'package:easy_pos/helpers/sql_helpers.dart';
import 'package:easy_pos/models/category.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

class CategoriesDropDown extends StatefulWidget {
  final int? selectedValue;
  final void Function(int?)? onChanged;
  const CategoriesDropDown(
      {required this.onChanged, this.selectedValue, super.key});

  @override
  State<CategoriesDropDown> createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
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
    return categories == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : (categories?.isEmpty ?? false)
            ? Center(
                child: Text('No categories found'),
              )
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: DropdownButton(
                            value: widget.selectedValue,
                            isExpanded: true,
                            underline: SizedBox(),
                            hint: Text('Select Category'),
                            items: [
                              for (var category in categories!)
                                DropdownMenuItem(
                                  child: Text(category.name ?? 'No name'),
                                  value: category.id,
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
