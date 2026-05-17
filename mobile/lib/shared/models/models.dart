import 'enums.dart';

/// User profile model matching public.users table.
class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;
  final String locale;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
    required this.locale,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        fullName: json['full_name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        role: UserRoleX.fromString(json['role'] as String),
        isVerified: json['is_verified'] as bool? ?? false,
        locale: json['locale'] as String? ?? 'en',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role.value,
        'is_verified': isVerified,
        'locale': locale,
      };
}

/// Product variant (stored as JSONB in products.variants).
class ProductVariant {
  final String name;
  final String value;
  final double priceModifier;
  final int stock;

  const ProductVariant({
    required this.name,
    required this.value,
    required this.priceModifier,
    required this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        name: json['name'] as String,
        value: json['value'] as String,
        priceModifier: (json['price_modifier'] as num).toDouble(),
        stock: json['stock'] as int,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'price_modifier': priceModifier,
        'stock': stock,
      };
}

/// Product model matching public.products table.
class ProductModel {
  final String id;
  final String vendorId;
  final String categoryId;
  final String title;
  final String? titleAm;
  final String description;
  final String? descriptionAm;
  final double basePrice;
  final Currency currency;
  final List<ProductVariant> variants;
  final List<String> images;
  final int stockLevel;
  final ProductStatus status;
  final bool isFeatured;
  final double? salePrice;
  final DateTime? saleStart;
  final DateTime? saleEnd;
  final double avgRating;
  final int reviewCount;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.vendorId,
    required this.categoryId,
    required this.title,
    this.titleAm,
    required this.description,
    this.descriptionAm,
    required this.basePrice,
    required this.currency,
    required this.variants,
    required this.images,
    required this.stockLevel,
    required this.status,
    required this.isFeatured,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    required this.avgRating,
    required this.reviewCount,
    required this.createdAt,
  });

  /// Effective price considering active sale.
  double get effectivePrice {
    if (salePrice != null && saleStart != null && saleEnd != null) {
      final now = DateTime.now();
      if (now.isAfter(saleStart!) && now.isBefore(saleEnd!)) {
        return salePrice!;
      }
    }
    return basePrice;
  }

  bool get isOnSale => effectivePrice < basePrice;
  bool get isInStock => stockLevel > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        vendorId: json['vendor_id'] as String,
        categoryId: json['category_id'] as String,
        title: json['title'] as String,
        titleAm: json['title_am'] as String?,
        description: json['description'] as String,
        descriptionAm: json['description_am'] as String?,
        basePrice: (json['base_price'] as num).toDouble(),
        currency: json['currency'] == 'KES' ? Currency.KES : Currency.ETB,
        variants: (json['variants'] as List<dynamic>? ?? [])
            .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList(),
        images: List<String>.from(json['images'] as List? ?? []),
        stockLevel: json['stock_level'] as int? ?? 0,
        status: ProductStatusX.fromString(json['status'] as String),
        isFeatured: json['is_featured'] as bool? ?? false,
        salePrice: (json['sale_price'] as num?)?.toDouble(),
        saleStart: json['sale_start'] != null
            ? DateTime.parse(json['sale_start'] as String)
            : null,
        saleEnd: json['sale_end'] != null
            ? DateTime.parse(json['sale_end'] as String)
            : null,
        avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: json['review_count'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Category model matching public.categories table.
class CategoryModel {
  final String id;
  final String name;
  final String? nameAm;
  final String slug;
  final String? parentId;
  final String? iconUrl;
  final int displayOrder;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameAm,
    required this.slug,
    this.parentId,
    this.iconUrl,
    required this.displayOrder,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        nameAm: json['name_am'] as String?,
        slug: json['slug'] as String,
        parentId: json['parent_id'] as String?,
        iconUrl: json['icon_url'] as String?,
        displayOrder: json['display_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}

/// Cart item model matching public.cart_items table.
class CartItemModel {
  final String id;
  final String cartId;
  final String productId;
  final Map<String, dynamic>? variant;
  final int quantity;
  // Joined data
  final ProductModel? product;

  const CartItemModel({
    required this.id,
    required this.cartId,
    required this.productId,
    this.variant,
    required this.quantity,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'] as String,
        cartId: json['cart_id'] as String,
        productId: json['product_id'] as String,
        variant: json['variant'] as Map<String, dynamic>?,
        quantity: json['quantity'] as int,
        product: json['products'] != null
            ? ProductModel.fromJson(json['products'] as Map<String, dynamic>)
            : null,
      );
}

/// Delivery address (JSONB in orders.delivery_address).
class DeliveryAddress {
  final String street;
  final String city;
  final String region;
  final String postalCode;
  final double lat;
  final double lng;

  const DeliveryAddress({
    required this.street,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.lat,
    required this.lng,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        street: json['street'] as String,
        city: json['city'] as String,
        region: json['region'] as String,
        postalCode: json['postal_code'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'region': region,
        'postal_code': postalCode,
        'lat': lat,
        'lng': lng,
      };
}

/// Order model matching public.orders table.
class OrderModel {
  final String id;
  final String customerId;
  final OrderStatus status;
  final double totalAmount;
  final Currency currency;
  final DeliveryAddress deliveryAddress;
  final PaymentGateway paymentMethod;
  final String? paymentReference;
  final String? notes;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.paymentReference,
    this.notes,
    this.estimatedDelivery,
    this.deliveredAt,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        status: OrderStatusX.fromString(json['status'] as String),
        totalAmount: (json['total_amount'] as num).toDouble(),
        currency: json['currency'] == 'KES' ? Currency.KES : Currency.ETB,
        deliveryAddress: DeliveryAddress.fromJson(
            json['delivery_address'] as Map<String, dynamic>),
        paymentMethod: json['payment_method'] == 'mpesa'
            ? PaymentGateway.mpesa
            : PaymentGateway.telebirr,
        paymentReference: json['payment_reference'] as String?,
        notes: json['notes'] as String?,
        estimatedDelivery: json['estimated_delivery'] != null
            ? DateTime.parse(json['estimated_delivery'] as String)
            : null,
        deliveredAt: json['delivered_at'] != null
            ? DateTime.parse(json['delivered_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
