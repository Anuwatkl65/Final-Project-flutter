import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/pb_service.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
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
    try {
      final data = await pb.getProducts();
      setState(() {
        products = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดข้อมูลล้มเหลว: $e')),
      );
    }
  }

  void _showForm({Product? product}) {
    if (product != null) {
      nameController.text = product.name;
      priceController.text = product.price.toString();
      stockController.text = product.stock.toString();
    } else {
      nameController.clear();
      priceController.clear();
      stockController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0;
              final stock = int.tryParse(stockController.text) ?? 0;

              try {
                if (product == null) {
                  await pb.addProduct(name, price, stock);
                } else {
                  await pb.updateProduct(product.id, name, price, stock);
                }
                Navigator.pop(context);
                fetchProducts();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('บันทึกล้มเหลว: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await pb.deleteProduct(product.id);
                Navigator.pop(context);
                fetchProducts();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ลบไม่สำเร็จ: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchProducts,
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final p = products[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(p.name),
                      subtitle: Text('฿${p.price} | Stock: ${p.stock}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(product: p)),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(p)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
