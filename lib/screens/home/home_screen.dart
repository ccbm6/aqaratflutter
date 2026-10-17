import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/property_card.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final properties = context.watch<PropertyProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, auth)),
              SliverToBoxAdapter(child: _buildSearchBar(properties)),
              SliverToBoxAdapter(child: _buildPurposeTabs(properties)),
              SliverToBoxAdapter(child: _buildCategoryChips(properties)),
              if (properties.query.isEmpty &&
                  properties.purposeFilter == null &&
                  properties.categoryFilter == null &&
                  properties.featured.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SectionTitle(title: '✨ عقارات مميزة'),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFeaturedList(properties)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SectionTitle(title: 'جميع العقارات'),
                  ),
                ),
              ] else
                const SliverToBoxAdapter(child: SizedBox(height: 6)),
              _buildGrid(properties),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('بوابة العقارات',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                Text(
                  auth.isLoggedIn ? 'أهلاً، ${auth.currentUser!.name}' : 'أهلاً بك 👋',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          if (!auth.isLoggedIn)
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('دخول'),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PropertyProvider properties) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: properties.setQuery,
        decoration: InputDecoration(
          hintText: 'ابحث عن عقار أو منطقة...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: properties.query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    properties.setQuery('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPurposeTabs(PropertyProvider properties) {
    Widget tab(String label, PropertyPurpose? value) {
      final selected = properties.purposeFilter == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => properties.setPurposeFilter(selected ? null : value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          tab('الكل', null),
          tab('للبيع', PropertyPurpose.sale),
          tab('للإيجار', PropertyPurpose.rent),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(PropertyProvider properties) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: PropertyCategory.values.map((c) {
          final selected = properties.categoryFilter == c;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text('${c.icon} ${c.label}'),
              selected: selected,
              onSelected: (_) => properties.setCategoryFilter(selected ? null : c),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedList(PropertyProvider properties) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: properties.featured.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(left: 12),
          child: SizedBox(width: 220, child: PropertyCard(property: properties.featured[i])),
        ),
      ),
    );
  }

  Widget _buildGrid(PropertyProvider properties) {
    final list = properties.filtered;
    if (list.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyState(icon: Icons.search_off, message: 'لا توجد عقارات مطابقة لبحثك'),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.66,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => PropertyCard(property: list[i]),
          childCount: list.length,
        ),
      ),
    );
  }
}
