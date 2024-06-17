import 'package:hive_flutter/hive_flutter.dart';
import '../database/product.dart';

class DatabaseHelper {
  static const String boxName = 'products';

  Future<void> insertProduct(Product product) async {
    final box = Hive.box<Product>(boxName);
    product.id = box.length + 1; // Auto-increment ID
    await box.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    final box = Hive.box<Product>(boxName);
    await box.put(product.id, product);
  }

  Future<void> deleteProduct(int id) async {
    final box = Hive.box<Product>(boxName);
    await box.delete(id);
  }

  Future<List<Product>> getProducts() async {
    final box = Hive.box<Product>(boxName);
    return box.values.toList();
  }
}
