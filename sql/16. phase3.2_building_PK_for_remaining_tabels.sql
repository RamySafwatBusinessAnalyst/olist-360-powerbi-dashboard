/* ============================================================
   PHASE 3 – STEP 0: COMPLETE MISSING PRIMARY KEYS
   Schema: olist360

   PURPOSE:
   --------
   - Add PRIMARY KEYS only to tables that do NOT have one yet
   - Prepare schema for Foreign Key enforcement
   - Avoid touching tables where PK already exists

   IMPORTANT RULES APPLIED:
   ------------------------
   1. Dimension / Parent tables → Single-column Primary Key
   2. Fact tables with natural grain → Composite Primary Key
   3. No DROP of existing PKs
   4. MariaDB-compatible syntax only

   TABLES ALREADY HAVING PK (SKIPPED):
   -----------------------------------
   - core_customers
   - core_reviews
   - results_* tables
   ============================================================ */

USE olist360;

-- ============================================================
-- 1) core_orders
-- ============================================================
/*
   core_orders:
   - Each row represents ONE order
   - order_id uniquely identifies an order
*/
ALTER TABLE core_orders
ADD PRIMARY KEY (order_id);

-- ============================================================
-- 2) core_products
-- ============================================================
/*
   core_products:
   - Each row represents ONE product
   - product_id is globally unique
*/
ALTER TABLE core_products
ADD PRIMARY KEY (product_id);

-- ============================================================
-- 3) core_sellers
-- ============================================================
/*
   core_sellers:
   - Each row represents ONE seller
   - seller_id uniquely identifies a seller
*/
ALTER TABLE core_sellers
ADD PRIMARY KEY (seller_id);

-- ============================================================
-- 4) ref_category_translation
-- ============================================================
/*
   ref_category_translation:
   - Reference / lookup table
   - Each category name appears once
   - Used as Parent table for products
*/
ALTER TABLE ref_category_translation
ADD PRIMARY KEY (product_category_name);

-- ============================================================
-- 5) core_order_items (COMPOSITE PRIMARY KEY)
-- ============================================================
/*
   core_order_items:
   - One order can contain multiple items
   - order_item_id is only unique WITHIN an order
   - Therefore, the grain is (order_id, order_item_id)
*/
ALTER TABLE core_order_items
ADD PRIMARY KEY (order_id, order_item_id);

-- ============================================================
-- 6) core_payments (COMPOSITE PRIMARY KEY)
-- ============================================================
/*
   core_payments:
   - One order may have multiple payment records
   - payment_sequential defines the sequence per order
   - Composite PK ensures row-level uniqueness
*/
ALTER TABLE core_payments
ADD PRIMARY KEY (order_id, payment_sequential);

-- ============================================================
-- 7) ref_geolocation (REFERENCE TABLE)
-- ============================================================
/*
   ref_geolocation:
   - as there is no column inthis tabels to make as PK, 
   - we will add  Surrogate Primary Key لـ ref_geolocation
*/
ALTER TABLE ref_geolocation
ADD COLUMN geolocation_row_id BIGINT NOT NULL AUTO_INCREMENT,
ADD PRIMARY KEY (geolocation_row_id);
CREATE INDEX idx_geolocation_zip_prefix
ON ref_geolocation (geolocation_zip_code_prefix);


-- ============================================================
-- END OF PK COMPLETION SCRIPT
-- ============================================================

/*
   RESULT AFTER EXECUTION:
   -----------------------
   ✅ All business and reference tables now have PRIMARY KEYS
   ✅ Fact tables have correct composite PKs
   ✅ core_reviews correctly uses a surrogate PK (already present)
   ✅ Schema is now READY for Foreign Key creation (Phase 3 – Step 1)
*/