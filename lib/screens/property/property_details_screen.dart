import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final properties = context.watch<PropertyProvider>();
    final auth = context.watch<AuthProvider>();
    final p = properties.all.firstWhere((e) => e.id == widget.propertyId);
    final isFav = properties.favoriteIds.contains(p.id);
    final canManage = auth.currentUser?.id == p.ownerId ||
        (auth.currentUser?.has('manage_properties') ?? false);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: AppColors.bg,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                onPressed: () => properties.toggleFavorite(p.id),
              ),
              if (canManage)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, properties, p.id),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: p.images.length,
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: p.images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey.shade300),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: p.images.length,
                        effect: const WormEffect(
                          activeDotColor: Colors.white,
                          dotColor: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: p.purpose == PropertyPurpose.sale
                              ? AppColors.saleColor
                              : AppColors.rentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p.purpose.label,
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Text('${p.category.icon} ${p.category.label}',
                          style: const TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(p.title,
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 17, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(p.location, style: const TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${_formatPrice(p.price)} ${p.currency.symbol}${p.purpose == PropertyPurpose.rent ? " / شهرياً" : ""}',
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _feature(Icons.square_foot, '${p.area.toStringAsFixed(0)} م²', 'المساحة'),
                        if (p.rooms > 0) _feature(Icons.bed_outlined, '${p.rooms}', 'غرف'),
                        if (p.bathrooms > 0)
                          _feature(Icons.bathtub_outlined, '${p.bathrooms}', 'حمامات'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('الوصف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(p.description,
                      style: const TextStyle(color: AppColors.textDark, height: 1.6)),
                  const SizedBox(height: 22),
                  const Text('معلومات المعلن',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(p.ownerName.isNotEmpty ? p.ownerName[0] : '?',
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(p.ownerName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launch('tel:${p.phone}'),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('اتصال'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launch(
                      'https://wa.me/${p.whatsapp.replaceAll('+', '')}'),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('واتساب'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ],
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

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(BuildContext context, PropertyProvider properties, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف العقار'),
        content: const Text('هل أنت متأكد من حذف هذا العقار؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              properties.removeProperty(id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
