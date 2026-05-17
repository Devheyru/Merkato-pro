# Feature Specification: Merkato-pro E-Commerce Platform

**Feature Branch**: `001-ecommerce-platform`

**Created**: 2026-05-17

**Status**: Draft

**Input**: User description: "Build an e-commerce platform based on Merkato-pro-SRS.docx and Constitution.md"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Customer Browse & Search Products (Priority: P1)

A customer visits the Merkato-pro marketplace and discovers products through browsing categories, searching by keywords, and exploring curated homepage content. They can view trending products, filter results by price/category/rating, sort by relevance or price, and get autocomplete suggestions while typing.

**Why this priority**: Product discovery is the entry point for all commerce. Without the ability to find products, no transactions can occur. This is the foundation of the entire customer journey.

**Independent Test**: Can be fully tested by navigating to the homepage, browsing categories, performing a search with filters, and verifying product listings display correctly with images, prices, and ratings.

**Acceptance Scenarios**:

1. **Given** a customer on the homepage, **When** they view the page, **Then** they see curated banners, trending products, and featured categories
2. **Given** a customer on the homepage, **When** they type 3+ characters in the search bar, **Then** autocomplete suggestions appear within 500ms
3. **Given** a customer performing a search, **When** they apply filters (category, price range, vendor, rating), **Then** results update to match only products meeting all selected criteria
4. **Given** search results displayed, **When** the customer selects a sort option (relevance, price ascending, price descending, newest), **Then** results reorder accordingly
5. **Given** a customer browsing categories, **When** they select a category, **Then** they see products within that category and its subcategories displayed in a grid/list with pagination

---

### User Story 2 - Customer Registration & Authentication (Priority: P1)

A new visitor creates an account using email/password or phone number, receives a verification email/SMS, and gains access to personalized features. Returning users log in via email/password, phone OTP, or Google OAuth. Sessions persist across devices, and users can reset forgotten passwords.

**Why this priority**: Authentication is a prerequisite for cart persistence, order placement, wishlists, reviews, and all personalized features. It is the identity foundation of the platform.

**Independent Test**: Can be fully tested by registering a new account, verifying email, logging in, logging out, and resetting a password — all without depending on other features.

**Acceptance Scenarios**:

1. **Given** a new visitor, **When** they complete the registration form with valid email and password, **Then** an account is created and a verification email is sent
2. **Given** a registered user with verified email, **When** they enter correct credentials, **Then** they are logged in and redirected to the homepage
3. **Given** a logged-in user, **When** they close the browser and return within 24 hours, **Then** their session is still active (JWT not expired)
4. **Given** a user who forgot their password, **When** they request a password reset, **Then** they receive a reset link via email and can set a new password
5. **Given** a user on the login page, **When** they choose "Sign in with Google", **Then** they are authenticated via OAuth and their account is created or linked

---

### User Story 3 - Shopping Cart & Wishlist Management (Priority: P1)

An authenticated customer adds products to their cart, adjusts quantities, removes items, and sees a real-time subtotal organized by vendor. They can also save products to a wishlist for future purchase. The cart persists across devices for logged-in users.

**Why this priority**: The cart is the critical bridge between product discovery and checkout. Without cart functionality, customers cannot accumulate items for purchase.

**Independent Test**: Can be fully tested by adding multiple products from different vendors to the cart, verifying vendor grouping and subtotals, adjusting quantities, removing items, and verifying persistence after page refresh.

**Acceptance Scenarios**:

1. **Given** a customer viewing a product, **When** they click "Add to Cart", **Then** the product is added and the cart icon updates with the new count
2. **Given** a cart with items from multiple vendors, **When** the customer views the cart, **Then** items are grouped by vendor with per-vendor subtotals and a grand total
3. **Given** a cart with an item, **When** the customer changes the quantity, **Then** the subtotal and grand total update immediately
4. **Given** an authenticated customer with cart items, **When** they log in from a different device, **Then** their cart contents are the same
5. **Given** a customer viewing a product, **When** they click "Save to Wishlist", **Then** the product appears in their wishlist and can be moved to cart later
6. **Given** items in the cart, **When** the system detects a price change or stock depletion, **Then** the customer is notified before proceeding to checkout

---

### User Story 4 - Order Checkout & Payment (Priority: P1)

A customer proceeds from their cart to checkout, provides a delivery address, selects a payment method (Telebirr for ETB or M-Pesa for KES), completes payment, and receives an order confirmation. Multi-vendor orders are automatically split into per-vendor sub-orders.

**Why this priority**: Checkout and payment are the revenue-generating core of the platform. This is where the marketplace delivers its primary value proposition.

**Independent Test**: Can be fully tested by filling a cart, entering delivery details, selecting a payment method, completing a test payment, and verifying order creation with correct status.

**Acceptance Scenarios**:

1. **Given** a customer with items in cart, **When** they click "Checkout", **Then** they see a checkout form with delivery address, payment method selection, and order summary
2. **Given** a customer at checkout, **When** they select Telebirr and complete payment, **Then** the payment is verified and an order is created with status "pending"
3. **Given** a multi-vendor cart, **When** the order is placed, **Then** separate sub-orders are created for each vendor with appropriate item allocation
4. **Given** a successful payment, **When** the order is confirmed, **Then** the customer receives a push notification and email confirmation with order details
5. **Given** a failed payment, **When** the payment gateway returns an error, **Then** no order is created and the customer sees a clear error message with retry option
6. **Given** a completed order, **When** the customer views order history, **Then** they can see all past orders with status, items, and total amount

---

### User Story 5 - Vendor Product Management (Priority: P1)

A vendor logs into their dashboard and manages their product catalog — creating new listings with title, description, images, pricing, variants (size, color), and stock levels. They can edit, deactivate, or delete products. Products require admin approval before becoming visible to customers.

**Why this priority**: Vendor product management is what populates the marketplace. Without vendors listing products, there is nothing for customers to buy.

**Independent Test**: Can be fully tested by a vendor creating a product with all required fields, uploading images, setting variants and stock, then editing and deactivating the product.

**Acceptance Scenarios**:

1. **Given** an approved vendor on their dashboard, **When** they click "Add Product", **Then** they see a form for title, description, price, category, images, variants, and stock
2. **Given** a vendor filling the product form, **When** they upload images, **Then** images are stored securely, auto-compressed to WebP format under 200KB
3. **Given** a vendor with a submitted product, **When** the admin approves it, **Then** the product becomes visible to customers on the marketplace
4. **Given** a vendor viewing their product list, **When** they edit a product's price or stock, **Then** the changes are reflected immediately (or after re-approval if required)
5. **Given** a vendor, **When** they deactivate a product, **Then** it is hidden from customers but preserved in the vendor's catalog for reactivation

---

### User Story 6 - Order Fulfillment & Delivery Tracking (Priority: P1)

After an order is placed, vendors accept or reject it, update status through fulfillment stages, and a delivery agent is assigned. Customers track their order in real-time through a timeline view showing each status change. Delivery agents update status via the mobile app.

**Why this priority**: Order fulfillment and tracking close the commerce loop. Without tracking, customers have no visibility into their purchases, leading to poor experience and support burden.

**Independent Test**: Can be fully tested by placing an order, having the vendor accept it, assigning a delivery agent, progressing through delivery stages, and verifying the customer sees real-time timeline updates.

**Acceptance Scenarios**:

1. **Given** a new order, **When** the vendor receives it, **Then** they can accept or reject it with notification sent to the customer
2. **Given** an accepted order, **When** the vendor marks it as "shipped", **Then** a delivery agent is assigned and the customer sees the status update
3. **Given** an in-transit order, **When** the delivery agent updates location/status, **Then** the customer sees real-time updates on their order tracking timeline
4. **Given** a delivery agent at the destination, **When** they mark the order as "delivered", **Then** the customer receives a push notification and the order status updates to "delivered"
5. **Given** an order with issues, **When** the customer initiates a return/refund request within the allowed window, **Then** the request is logged and the vendor/admin is notified

---

### User Story 7 - Vendor Dashboard & Analytics (Priority: P2)

Vendors access a comprehensive dashboard showing sales metrics, revenue charts, order notifications, and payout history. They can filter analytics by time period, manage their store profile, and configure store branding.

**Why this priority**: While vendors can operate without analytics in MVP, the dashboard is critical for vendor retention and operational efficiency. It enables vendors to make informed business decisions.

**Independent Test**: Can be fully tested by a vendor logging in, viewing dashboard metrics, filtering charts by date range, and verifying data accuracy against known order/sales records.

**Acceptance Scenarios**:

1. **Given** an approved vendor, **When** they access their dashboard, **Then** they see total revenue, pending orders, total products, and average rating
2. **Given** a vendor on the analytics page, **When** they select a date range filter, **Then** sales charts update to reflect the selected period
3. **Given** a new order placed for a vendor's product, **When** the vendor is on the dashboard, **Then** they receive a real-time notification
4. **Given** a vendor with completed sales, **When** they view payout history, **Then** they see all past payouts with amounts, dates, and commission deducted
5. **Given** a vendor, **When** they edit their store profile (logo, banner, description), **Then** the changes are reflected on their public storefront

---

### User Story 8 - Admin Platform Management (Priority: P1)

Platform administrators access a dedicated panel to manage users, approve/reject vendor applications, moderate product listings, oversee orders, configure platform settings (commission rates, banners), and view platform-wide analytics. All admin actions are logged for audit purposes.

**Why this priority**: Admin oversight is essential for platform integrity, vendor quality control, content moderation, and financial governance. The platform cannot operate safely without admin controls.

**Independent Test**: Can be fully tested by an admin logging in, reviewing a vendor application, approving/rejecting it, moderating a product listing, adjusting platform commission, and verifying audit log entries.

**Acceptance Scenarios**:

1. **Given** an admin on the dashboard, **When** they view the overview, **Then** they see platform-wide metrics: total users, vendors, orders, revenue
2. **Given** a pending vendor application, **When** the admin reviews and approves it, **Then** the vendor receives notification and gains access to the vendor dashboard
3. **Given** a submitted product listing, **When** the admin reviews and approves it, **Then** the product becomes visible to customers
4. **Given** the admin on settings page, **When** they change the platform commission rate, **Then** the new rate applies to all future transactions
5. **Given** any admin action, **When** it is performed, **Then** an entry is written to the append-only audit log with admin ID, action, timestamp, and details

---

### User Story 9 - Reviews & Ratings (Priority: P1)

Customers who have received a delivered product can submit a star rating (1-5) and text review. Each customer may review a product only once. Reviews appear on the product detail page, and the aggregate rating updates automatically. Vendors can reply to reviews. Admins can moderate reviews.

**Why this priority**: Reviews and ratings build trust in the marketplace, help customers make purchase decisions, and incentivize vendors to maintain quality. They are a core marketplace trust mechanism.

**Independent Test**: Can be fully tested by a customer with a delivered order submitting a review, verifying it appears on the product page, checking the aggregate rating updates, and testing vendor reply functionality.

**Acceptance Scenarios**:

1. **Given** a customer with a delivered order, **When** they submit a review with rating and text, **Then** the review is saved and displayed on the product detail page
2. **Given** a customer who already reviewed a product, **When** they attempt to review again, **Then** the system prevents duplicate reviews
3. **Given** multiple reviews on a product, **When** a customer views the product, **Then** they see the aggregate star rating, review count, and individual reviews sorted by most recent
4. **Given** a review on their product, **When** the vendor submits a reply, **Then** the reply appears nested under the original review
5. **Given** a reported or inappropriate review, **When** an admin moderates it, **Then** the review is hidden and the aggregate rating recalculates

---

### User Story 10 - Multi-Language Support (Priority: P2)

The platform supports English and Amharic as display languages. Users can switch languages from any page, and the selection persists across sessions. All user-facing text uses internationalization keys — no hardcoded strings.

**Why this priority**: Amharic support is critical for the Ethiopian market segment but the platform is functional in English alone. This can be incrementally added after core commerce features.

**Independent Test**: Can be fully tested by switching between English and Amharic, verifying all UI labels translate correctly, refreshing the page to confirm persistence, and checking that no hardcoded strings appear.

**Acceptance Scenarios**:

1. **Given** a user on any page, **When** they select Amharic from the language switcher, **Then** all UI labels, buttons, and navigation update to Amharic
2. **Given** a user who selected Amharic, **When** they close the browser and return, **Then** the platform loads in Amharic
3. **Given** the platform in any language, **When** inspecting the UI, **Then** no hardcoded English strings appear — all text uses i18n keys

---

### Edge Cases

- What happens when a product goes out of stock while in a customer's cart? The system notifies the customer and prevents checkout for unavailable items.
- How does the system handle concurrent purchases depleting stock? Stock is validated at checkout time with optimistic locking; late buyers receive a "sold out" notification.
- What happens when a payment webhook arrives but the order has been cancelled? The system issues an automatic refund and logs the event.
- How does the system handle vendor account suspension? All vendor products are hidden, active orders continue to fulfillment, and the vendor receives notification with reason.
- What happens when the Telebirr/M-Pesa API is unavailable? The system displays a service-unavailable message for that payment method and suggests alternatives if available.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow customers to register via email/password, phone OTP, or Google OAuth
- **FR-002**: System MUST enforce email/phone verification before account activation
- **FR-003**: System MUST expire JWT sessions after 24 hours of inactivity
- **FR-004**: System MUST enforce Row-Level Security on all data tables to prevent cross-user/cross-vendor data access
- **FR-005**: System MUST provide full-text product search with autocomplete suggestions after 3+ characters typed
- **FR-006**: System MUST support product filtering by category, price range, vendor, and rating
- **FR-007**: System MUST support product sorting by relevance, price (ascending/descending), and newest
- **FR-008**: System MUST display a homepage with curated banners, trending products, and featured categories
- **FR-009**: System MUST allow vendors to create product listings with title, description, images, pricing, category, variants, and stock levels
- **FR-010**: System MUST support product variants (size, color, etc.) with individual pricing and stock tracking
- **FR-011**: System MUST auto-compress uploaded product images to WebP format under 200KB
- **FR-012**: System MUST require admin approval before new products become publicly visible
- **FR-013**: System MUST persist shopping cart across devices for authenticated users
- **FR-014**: System MUST display cart items grouped by vendor with per-vendor subtotals
- **FR-015**: System MUST validate item availability and current pricing at checkout time
- **FR-016**: System MUST allow customers to save products to a wishlist
- **FR-017**: System MUST integrate with Telebirr API for ETB mobile money payments
- **FR-018**: System MUST integrate with M-Pesa Daraja API for KES mobile money payments
- **FR-019**: System MUST handle payment through server-side Edge Functions only — no client-side payment logic
- **FR-020**: System MUST split multi-vendor orders into per-vendor sub-orders automatically
- **FR-021**: System MUST support order status progression: pending → confirmed → processing → shipped → in_transit → delivered
- **FR-022**: System MUST send push and email notifications at each order status transition
- **FR-023**: System MUST allow vendors to accept, reject, or update order status
- **FR-024**: System MUST assign delivery agents to shipped orders
- **FR-025**: System MUST provide real-time order tracking via a customer-facing timeline view
- **FR-026**: System MUST allow customers to submit one review per delivered product (1-5 stars + text)
- **FR-027**: System MUST calculate and display aggregate product ratings
- **FR-028**: System MUST allow vendors to publicly reply to reviews
- **FR-029**: System MUST allow admins to moderate reviews (approve, hide, delete)
- **FR-030**: System MUST provide a vendor dashboard with revenue, orders, products, and rating metrics
- **FR-031**: System MUST provide vendor sales analytics with date-range filtering
- **FR-032**: System MUST provide an admin panel with user management, vendor approval, product moderation, order oversight, and platform settings
- **FR-033**: System MUST log all admin actions to an append-only audit log
- **FR-034**: System MUST collect a configurable commission percentage (default 5%) on completed transactions
- **FR-035**: System MUST support English and Amharic display languages with i18n architecture

### Key Entities

- **User**: Represents all platform actors (customer, vendor, delivery agent, admin) with role-based differentiation. Key attributes: ID, email, phone, name, role, verification status, created_at.
- **Vendor/Store**: Represents an approved seller on the platform. Key attributes: ID, user_id, store_name, logo, banner, description, approval_status, commission_rate.
- **Product**: A sellable item listed by a vendor. Key attributes: ID, vendor_id, title, description, price, category_id, images, variants (JSONB), stock_level, status, deleted_at.
- **Category**: Hierarchical classification for products. Key attributes: ID, name, parent_id, icon, display_order.
- **Cart / CartItem**: Temporary shopping container for customers. Key attributes: ID, user_id, product_id, variant, quantity.
- **Order**: A confirmed purchase by a customer. Key attributes: ID, customer_id, status, total_amount, delivery_address, payment_method, payment_reference, created_at.
- **OrderItem**: Individual line items within an order, linked to vendor sub-orders. Key attributes: ID, order_id, product_id, vendor_id, quantity, unit_price, subtotal.
- **Payment**: Transaction record from Telebirr or M-Pesa. Key attributes: ID, order_id, gateway, transaction_ref, amount, currency, status.
- **Review**: Customer feedback on a delivered product. Key attributes: ID, customer_id, product_id, rating, text, photos, vendor_reply, created_at.
- **AuditLog**: Append-only record of admin/system actions. Key attributes: ID, actor_id, action, entity_type, entity_id, details (JSONB), timestamp.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Customers can complete the full journey from product search to order confirmation in under 5 minutes
- **SC-002**: The platform supports 1,000 concurrent users browsing and purchasing without degradation
- **SC-003**: Product search returns relevant results within 1 second for 95% of queries
- **SC-004**: Customers receive order status notifications within 30 seconds of a status change
- **SC-005**: Vendors can create and publish a new product listing in under 10 minutes
- **SC-006**: 90% of customers can complete their first purchase without contacting support
- **SC-007**: The platform correctly splits multi-vendor orders into per-vendor sub-orders with 100% accuracy
- **SC-008**: Payment success rate is at least 95% when the payment gateway is available
- **SC-009**: The web application loads initial content within 2.5 seconds on a 3G mobile connection
- **SC-010**: The mobile application starts within 3 seconds on mid-range devices
- **SC-011**: Admin actions are reflected in the audit log within 5 seconds of execution
- **SC-012**: The platform operates with 99.5% uptime excluding scheduled maintenance windows

## Assumptions

- Users have access to smartphones or computers with stable internet connectivity
- Telebirr and M-Pesa APIs are available and stable; the platform is not responsible for third-party gateway downtime
- The platform initially targets Ethiopia (ETB currency, Telebirr) and Kenya (KES currency, M-Pesa)
- Vendors are responsible for product accuracy and fulfillment; the platform acts as an intermediary
- Vendor onboarding requires manual admin approval; automated KYC verification is deferred to a future phase
- The platform does not handle physical logistics directly; delivery agents are managed as platform users
- Card payment integration is deferred to a future phase
- Guest checkout is deferred; only authenticated users can place orders in the initial release
- The mobile app will be distributed via Google Play Store and Apple App Store
- Email delivery depends on the availability of the configured SMTP provider
