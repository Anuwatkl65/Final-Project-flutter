import 'package:pocketbase/pocketbase.dart';
import '../models/product.dart';

class PBService {
  // ✅ สำหรับ Flutter Web ให้ใช้ 127.0.0.1
  // ✅ สำหรับ Emulator ให้เปลี่ยนเป็น 10.0.2.2
  static const baseUrl = 'http://127.0.0.1:8090';
  final pb = PocketBase(baseUrl);

  final String collection = 'products';

  Future<List<Product>> getProducts() async {
    try {
      final result = await pb.collection(collection).getFullList();
      return result.map((r) => Product.fromJson(r.data)).toList();
    } catch (e) {
      print('❌ Error getting products: $e');
      return [];
    }
  }

  Future<void> addProduct(String name, double price, int stock) async {
    await pb.collection(collection).create(body: {
      'name': name,
      'price': price,
      'stock': stock,
    });
  }

  Future<void> updateProduct(String id, String name, double price, int stock) async {
    await pb.collection(collection).update(id, body: {
      'name': name,
      'price': price,
      'stock': stock,
    });
  }

  Future<void> deleteProduct(String id) async {
    await pb.collection(collection).delete(id);
  }

  // ✅ ฟังก์ชันทดสอบการเชื่อมต่อ PocketBase
  Future<void> testConnection() async {
    try {
      final result = await pb.health.check();
      print('✅ Connected to PocketBase: ${result.message}');
    } catch (e) {
      print('❌ Connection failed: $e');
    }
  }
}
