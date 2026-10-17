import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/property_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<PropertyProvider>().favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border, message: 'لم تقم بإضافة أي عقار إلى المفضلة بعد')
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.66,
              ),
              itemCount: favorites.length,
              itemBuilder: (_, i) => PropertyCard(property: favorites[i]),
            ),
    );
  }
}
