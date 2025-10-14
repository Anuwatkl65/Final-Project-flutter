import 'package:pocketbase/pocketbase.dart';
import 'package:faker/faker.dart';

Future<void> seedProducts() async {
  final pb = PocketBase('http://127.0.0.1:8090');

  // ✅ login ด้วย admin ก่อน
  await pb.admins.authWithPassword('admin@ubu.ac.th', 'Adam_123456');

  final result = await pb.collection('products').getList(perPage: 1);
  if (result.totalItems > 0) {
    print('Products already seeded!');
    return;
  }

  final faker = Faker();
  for (int i = 0; i < 20; i++) {
    await pb.collection('products').create(body: {
      'name': faker.food.dish(),
      'price': faker.randomGenerator.integer(500, min: 10),
      'stock': faker.randomGenerator.integer(100, min: 1),
    });
  }

  print('✅ Seeded 20 products!');
}

Future<void> main() async {
  await seedProducts();
}
