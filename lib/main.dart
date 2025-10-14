import 'package:flutter/material.dart';
import 'models/product.dart';
import 'services/pb_service.dart';

void main() {
  runApp(const ProductApp());
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: const ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final PBService pb = PBService();
  List<Product> products = [];
  bool loading = true;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => loading = true);
    final data = await pb.getProducts();
    setState(() {
      products = data;
      loading = false;
    });
  }

  void _showForm({Product? product}) {
    nameController.text = product?.name ?? '';
    priceController.text = product?.price.toString() ?? '';
    stockController.text = product?.stock.toString() ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'เพิ่มสินค้าใหม่' : 'แก้ไขสินค้า'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อสินค้า',
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'ราคา',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'จำนวนสินค้า',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('บันทึก'),
            onPressed: () async {
              final name = nameController.text;
              final price = double.tryParse(priceController.text) ?? 0;
              final stock = int.tryParse(stockController.text) ?? 0;

              if (product == null) {
                await pb.addProduct(name, price, stock);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('เพิ่มสินค้าเรียบร้อย!')),
                );
              } else {
                await pb.updateProduct(product.id, name, price, stock);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('แก้ไขข้อมูลสำเร็จ!')),
                );
              }

              if (context.mounted) {
                Navigator.pop(context);
                fetchProducts();
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ลบสินค้า'),
        content: Text('คุณแน่ใจหรือไม่ที่จะลบ "${product.name}" ?'),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('ลบ'),
            onPressed: () async {
              await pb.deleteProduct(product.id);
              Navigator.pop(context);
              fetchProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ลบสินค้าเรียบร้อย!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสินค้า'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchProducts,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มสินค้า'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text('ยังไม่มีสินค้าในระบบ'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final p = products[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.store),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('฿${p.price} | คงเหลือ ${p.stock} ชิ้น'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () => _showForm(product: p),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(p),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
