enum PropertyPurpose { sale, rent }
enum PropertyCategory { apartment, villa, land, office, shop, chalet }

/// العملات المستخدمة في الإعلانات العقارية في اليمن
enum PropertyCurrency { yer, usd, sar }

extension PropertyCurrencyX on PropertyCurrency {
  String get label {
    switch (this) {
      case PropertyCurrency.yer:
        return 'ريال يمني';
      case PropertyCurrency.usd:
        return 'دولار أمريكي';
      case PropertyCurrency.sar:
        return 'ريال سعودي';
    }
  }

  String get symbol {
    switch (this) {
      case PropertyCurrency.yer:
        return 'ر.ي';
      case PropertyCurrency.usd:
        return '\$';
      case PropertyCurrency.sar:
        return 'ر.س';
    }
  }
}

extension PropertyPurposeX on PropertyPurpose {
  String get label => this == PropertyPurpose.sale ? 'للبيع' : 'للإيجار';
}

extension PropertyCategoryX on PropertyCategory {
  String get label {
    switch (this) {
      case PropertyCategory.apartment:
        return 'شقة';
      case PropertyCategory.villa:
        return 'فيلا';
      case PropertyCategory.land:
        return 'أرض';
      case PropertyCategory.office:
        return 'مكتب';
      case PropertyCategory.shop:
        return 'محل تجاري';
      case PropertyCategory.chalet:
        return 'شاليه';
    }
  }

  String get icon {
    switch (this) {
      case PropertyCategory.apartment:
        return '🏢';
      case PropertyCategory.villa:
        return '🏡';
      case PropertyCategory.land:
        return '🗺️';
      case PropertyCategory.office:
        return '🏬';
      case PropertyCategory.shop:
        return '🏪';
      case PropertyCategory.chalet:
        return '🏖️';
    }
  }
}

class PropertyModel {
  final String id;
  String title;
  String description;
  double price;
  PropertyCurrency currency;
  PropertyPurpose purpose;
  PropertyCategory category;
  List<String> images; // روابط أو مسارات صور محلية
  String location;
  double area;
  int rooms;
  int bathrooms;
  final String ownerId;
  String ownerName;
  String phone;
  String whatsapp;
  final DateTime createdAt;
  bool isFeatured;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currency = PropertyCurrency.yer,
    required this.purpose,
    required this.category,
    required this.images,
    required this.location,
    required this.area,
    required this.rooms,
    required this.bathrooms,
    required this.ownerId,
    required this.ownerName,
    required this.phone,
    required this.whatsapp,
    DateTime? createdAt,
    this.isFeatured = false,
  }) : createdAt = createdAt ?? DateTime.now();
}
