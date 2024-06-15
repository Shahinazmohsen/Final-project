import 'package:easy_pos/models/product.dart';

class OrderItem {
  int? orderId;
  int? productCount;
  int? productId;
  Product? product;

  OrderItem();

  OrderItem.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    productCount = json['productCount'];
    productId = json['productId'];
    product = Product.fromJson(json);
  }
}
