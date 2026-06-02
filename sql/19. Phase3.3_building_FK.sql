/* ============================================================
   PHASE 3 – FOREIGN KEY ENFORCEMENT
   Schema: olist360

   PURPOSE:
   --------
   - Enforce all logical relationships as physical Foreign Keys
   - Protect referential integrity at database level
   - Prevent orphan records and invalid deletes

   DESIGN RULES APPLIED:
   ---------------------
   - Parent tables own Primary Keys
   - Child tables store Foreign Keys
   - ON UPDATE CASCADE
   - ON DELETE RESTRICT
   ============================================================ */

USE olist360;

-- ============================================================
-- 1) Customers → Orders
-- ============================================================
ALTER TABLE core_orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES core_customers(customer_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- ============================================================
-- 2) Category Translation → Products
-- ============================================================
ALTER TABLE core_products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (product_category_name)
REFERENCES ref_category_translation(product_category_name)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- ============================================================
-- 3) Orders → Order Items
-- ============================================================
ALTER TABLE core_order_items
ADD CONSTRAINT fk_items_orders
FOREIGN KEY (order_id)
REFERENCES core_orders(order_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- ============================================================
-- 4) Products → Order Items
-- ============================================================
ALTER TABLE core_order_items
ADD CONSTRAINT fk_items_products
FOREIGN KEY (product_id)
REFERENCES core_products(product_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- ============================================================
-- 5) Sellers → Order Items
-- ============================================================
ALTER TABLE core_order_items
ADD CONSTRAINT fk_items_sellers
FOREIGN KEY (seller_id)
REFERENCES core_sellers(seller_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- ============================================================
-- 6) Orders → Payments
-- ============================================================
ALTER TABLE core_payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id)
REFERENCES core_orders(order_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- ============================================================
-- 7) Orders → Reviews
-- ============================================================
ALTER TABLE core_reviews
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id)
REFERENCES core_orders(order_id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

-- ============================================================
-- END OF PHASE 3 – FOREIGN KEY ENFORCEMENT
-- ============================================================

/*
   RESULT AFTER EXECUTION:
   -----------------------
   ✅ All core relationships are physically enforced
   ✅ Orphan inserts are prevented at DB level
   ✅ Accidental deletes are blocked
   ✅ Data model is production‑ready
*/