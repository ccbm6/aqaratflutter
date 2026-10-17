import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/yemen_data.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_widgets.dart';

/// شاشة إضافة عقار جديد: يقوم صاحب العقار برفع صور العقار وبياناته
/// وبيانات التواصل ليتم عرضها للباحثين عن شراء أو استئجار عقار.
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();
  final _area = TextEditingController();
  final _rooms = TextEditingController(text: '0');
  final _bathrooms = TextEditingController(text: '0');
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();

  PropertyPurpose _purpose = PropertyPurpose.sale;
  PropertyCategory _category = PropertyCategory.apartment;
  PropertyCurrency _currency = PropertyCurrency.yer;
  String _governorate = yemenGovernorates.first;
  final List<XFile> _pickedImages = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _phone.text = user?.phone ?? '';
    _whatsapp.text = user?.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عقار جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagesPicker(),
              const SizedBox(height: 18),
              const Text('نوع العرض', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: PropertyPurpose.values.map((p) {
                  final selected = _purpose == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _purpose = p),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: selected ? AppColors.primary : Colors.grey.shade300),
                        ),
                        child: Text(p.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selected ? Colors.white : AppColors.textDark,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('نوع العقار', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<PropertyCategory>(
                value: _category,
                items: PropertyCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text('${c.icon} ${c.label}')))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                  controller: _title, label: 'عنوان الإعلان', icon: Icons.title,
                  validator: _required),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                maxLines: 4,
                validator: _required,
                decoration: const InputDecoration(
                    labelText: 'وصف العقار', alignLabelWithHint: true),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _price,
                      label: 'السعر',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<PropertyCurrency>(
                      value: _currency,
                      isExpanded: true,
                      items: PropertyCurrency.values
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                      decoration: const InputDecoration(labelText: 'العملة'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _governorate,
                isExpanded: true,
                items: yemenGovernorates
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _governorate = v!),
                decoration: const InputDecoration(
                  labelText: 'المحافظة',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                  controller: _location, label: 'المديرية / الحي / الشارع', icon: Icons.location_on_outlined,
                  validator: _required),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _area,
                      label: 'المساحة (م²)',
                      icon: Icons.square_foot,
                      keyboardType: TextInputType.number,
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _rooms,
                      label: 'غرف',
                      icon: Icons.bed_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _bathrooms,
                      label: 'حمامات',
                      icon: Icons.bathtub_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('بيانات التواصل', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(
                  controller: _phone, label: 'رقم الهاتف', icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone, validator: _required),
              const SizedBox(height: 14),
              CustomTextField(
                  controller: _whatsapp, label: 'رقم الواتساب', icon: Icons.chat_bubble_outline,
                  keyboardType: TextInputType.phone, validator: _required),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('نشر الإعلان'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('صور العقار', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._pickedImages.map((img) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(img.path),
                              width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() => _pickedImages.remove(img)),
                            child: const CircleAvatar(
                              radius: 11,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        if (_pickedImages.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('سيتم استخدام صور توضيحية افتراضية إن لم تقم برفع صور',
                style: TextStyle(fontSize: 11.5, color: AppColors.textGrey)),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _pickedImages.add(picked));
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser!;
    final images = _pickedImages.isNotEmpty
        ? _pickedImages.map((e) => e.path).toList()
        : [
            'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/900/650',
          ];

    final property = PropertyModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim(),
      price: double.tryParse(_price.text) ?? 0,
      currency: _currency,
      purpose: _purpose,
      category: _category,
      images: images,
      location: '$_governorate - ${_location.text.trim()}',
      area: double.tryParse(_area.text) ?? 0,
      rooms: int.tryParse(_rooms.text) ?? 0,
      bathrooms: int.tryParse(_bathrooms.text) ?? 0,
      ownerId: user.id,
      ownerName: user.name,
      phone: _phone.text.trim(),
      whatsapp: _whatsapp.text.trim(),
    );

    context.read<PropertyProvider>().addProperty(property);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نشر إعلان العقار بنجاح ✅')),
    );
  }
}
