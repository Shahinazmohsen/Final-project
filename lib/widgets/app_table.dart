import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final List<DataColumn> columns;
  final DataTableSource source;
  const AppTable({required this.columns, required this.source, super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(iconTheme: IconThemeData(color: Colors.black, size: 25)),
      child: PaginatedDataTable2(
        onPageChanged: (index) {},
        empty: Center(
          child: Text('No data found'),
        ),
        hidePaginator: false,
        minWidth: 800,
        fit: FlexFit.tight,
        isHorizontalScrollBarVisible: true,
        rowsPerPage: 15,
        horizontalMargin: 20,
        checkboxHorizontalMargin: 12,
        columnSpacing: 20,
        wrapInCard: false,
        renderEmptyRowsInTheEnd: false,
        headingTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        headingRowColor:
            MaterialStatePropertyAll(Theme.of(context).primaryColor),
        border: TableBorder.all(color: Colors.black),
        columns: columns,
        source: source,
      ),
    );
  }
}