import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/property_model.dart';
import '../providers/property_provider.dart';
import '../theme/app_theme.dart';
import '../screens/property/property_details_screen.dart';

/// بطاقة عرض عقار: صور متقلبة (Carousel) قابلة للسحب + شارة السعر
/// ونوع العرض (بيع/إيجار) + زر مفضلة.
class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final _pageController = PageController();
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final isFav = context.watch<PropertyProvider>().favoriteIds.contains(p.id);
    final purposeColor =
        p.purpose == PropertyPurpose.sale ? AppColors.saleColor : AppColors.rentColor;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailsScreen(propertyId: p.id)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 11,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: p.images.length,
                    onPageChanged: (i) => setState(() => _currentImage = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: p.images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
                if (p.images.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: p.images.length,
                        effect: const WormEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: purposeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.purpose.label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: IconButton(
                    onPressed: () =>
                        context.read<PropertyProvider>().toggleFavorite(p.id),
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.danger : Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ),
                if (p.isFeatured)
                  Positioned(
                    bottom: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('مميز',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppColors.textGrey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatPrice(p.price)} ر.س${p.purpose == PropertyPurpose.rent ? " / شهرياً" : ""}',
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.square_foot, size: 15, color: AppColors.textGrey),
                          const SizedBox(width: 2),
                          Text('${p.area.toStringAsFixed(0)} م²',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
