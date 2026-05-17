/// Merkato-pro Dart Data Models
/// Maps to the PostgreSQL schema defined in data-model.md
/// Used across the mobile app for type-safe data access.
library;

// ============================================================
// Enums
// ============================================================

enum UserRole { customer, vendor, deliveryAgent, admin }

enum VendorApprovalStatus { pending, approved, rejected, suspended }

enum ProductStatus { draft, pendingApproval, approved, rejected, deactivated }

enum Currency { ETB, KES }

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  inTransit,
  delivered,
  cancelled,
  refundRequested,
  refunded,
}

enum VendorItemStatus { pending, accepted, rejected, processing, shipped }

enum PaymentGateway { telebirr, mpesa }

enum PaymentStatus { initiated, pending, completed, failed, refunded }

// ============================================================
// Extension: Enum serialization helpers
// ============================================================

extension UserRoleX on UserRole {
  String get value => switch (this) {
        UserRole.customer => 'customer',
        UserRole.vendor => 'vendor',
        UserRole.deliveryAgent => 'delivery_agent',
        UserRole.admin => 'admin',
      };

  static UserRole fromString(String s) => switch (s) {
        'customer' => UserRole.customer,
        'vendor' => UserRole.vendor,
        'delivery_agent' => UserRole.deliveryAgent,
        'admin' => UserRole.admin,
        _ => UserRole.customer,
      };
}

extension OrderStatusX on OrderStatus {
  String get value => switch (this) {
        OrderStatus.pending => 'pending',
        OrderStatus.confirmed => 'confirmed',
        OrderStatus.processing => 'processing',
        OrderStatus.shipped => 'shipped',
        OrderStatus.inTransit => 'in_transit',
        OrderStatus.delivered => 'delivered',
        OrderStatus.cancelled => 'cancelled',
        OrderStatus.refundRequested => 'refund_requested',
        OrderStatus.refunded => 'refunded',
      };

  static OrderStatus fromString(String s) => switch (s) {
        'pending' => OrderStatus.pending,
        'confirmed' => OrderStatus.confirmed,
        'processing' => OrderStatus.processing,
        'shipped' => OrderStatus.shipped,
        'in_transit' => OrderStatus.inTransit,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        'refund_requested' => OrderStatus.refundRequested,
        'refunded' => OrderStatus.refunded,
        _ => OrderStatus.pending,
      };
}

extension ProductStatusX on ProductStatus {
  String get value => switch (this) {
        ProductStatus.draft => 'draft',
        ProductStatus.pendingApproval => 'pending_approval',
        ProductStatus.approved => 'approved',
        ProductStatus.rejected => 'rejected',
        ProductStatus.deactivated => 'deactivated',
      };

  static ProductStatus fromString(String s) => switch (s) {
        'draft' => ProductStatus.draft,
        'pending_approval' => ProductStatus.pendingApproval,
        'approved' => ProductStatus.approved,
        'rejected' => ProductStatus.rejected,
        'deactivated' => ProductStatus.deactivated,
        _ => ProductStatus.draft,
      };
}
