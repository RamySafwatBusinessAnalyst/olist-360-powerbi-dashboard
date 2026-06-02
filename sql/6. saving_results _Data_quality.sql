/* ============================================================================/* ========================================================================= 360 - Step 3: Data Quality Logging (Store results in MySQL)
   Database: olist360

   What this script does:
   1) Creates DQ logging tables (dq_runs, dq_results) if not exist
   2) Generates a unique run_id for this execution
   3) Stores:
      - Row counts for all raw tables
      - Missing values checks (including numeric columns)
      - Duplicate checks:
          a) Unique-key duplicates (count of duplicate key groups & extra rows)
          b) Composite-key duplicates (same idea)
          c) Full-row duplicates for small/medium tables
      - Heavy full-row duplicates for big tables are OPTIONAL (commented)

   How to use:
   - Run this script AFTER Step 2 (after loading all 9 tables)
   - Re-run after cleaning to compare runs (each run has its own run_id)

   ============================================================================ */

USE olist360;

-- ----------------------------------------------------------------
-- Fix collation mismatch for user variables (like @run_id)
-- ----------------------------------------------------------------
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- 1) Create logging tables (run registry + results)
-- ============================================================

CREATE TABLE IF NOT EXISTS dq_runs (
  run_id      VARCHAR(40) PRIMARY KEY,
  run_stage   VARCHAR(100) NOT NULL,        -- e.g., 'raw_load', 'post_clean'
  notes       VARCHAR(255) NULL,
  started_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dq_results (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  run_id      VARCHAR(40) NOT NULL,
  check_group VARCHAR(50) NOT NULL,         -- e.g., 'row_count','missing','dup_unique','dup_composite','dup_fullrow'
  table_name  VARCHAR(80) NOT NULL,
  metric_name VARCHAR(120) NOT NULL,        -- e.g., 'missing_order_id'
  metric_value BIGINT NULL,                 -- numeric metric
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_run (run_id),
  INDEX idx_run_table (run_id, table_name),
  CONSTRAINT fk_dq_run FOREIGN KEY (run_id) REFERENCES dq_runs(run_id)
);

-- ============================================================
-- 2) Create a unique Run ID and register the run
-- ============================================================

/* run_id is a unique identifier for this execution (timestamp-based). */
SET @run_id =
  CAST(DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s') AS CHAR CHARACTER SET utf8mb4)
  COLLATE utf8mb4_unicode_ci;

/* Set a stage label so you can compare runs across project phases. */
SET @run_stage = 'raw_load';   -- change later to 'post_clean', 'post_fix', etc.
SET @run_notes = 'Step 3 DQ checks after loading raw tables';

INSERT INTO dq_runs (run_id, run_stage, notes)
VALUES (@run_id, @run_stage, @run_notes);

-- ============================================================
-- 3) Store Row Counts (Import confirmation)
-- ============================================================

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'row_count', 'raw_orders', 'row_count', COUNT(*) FROM raw_orders
UNION ALL SELECT @run_id, 'row_count', 'raw_customers', 'row_count', COUNT(*) FROM raw_customers
UNION ALL SELECT @run_id, 'row_count', 'raw_order_items', 'row_count', COUNT(*) FROM raw_order_items
UNION ALL SELECT @run_id, 'row_count', 'raw_order_payments', 'row_count', COUNT(*) FROM raw_order_payments
UNION ALL SELECT @run_id, 'row_count', 'raw_order_reviews', 'row_count', COUNT(*) FROM raw_order_reviews
UNION ALL SELECT @run_id, 'row_count', 'raw_products', 'row_count', COUNT(*) FROM raw_products
UNION ALL SELECT @run_id, 'row_count', 'raw_sellers', 'row_count', COUNT(*) FROM raw_sellers
UNION ALL SELECT @run_id, 'row_count', 'raw_geolocation', 'row_count', COUNT(*) FROM raw_geolocation
UNION ALL SELECT @run_id, 'row_count', 'raw_category_translation', 'row_count', COUNT(*) FROM raw_category_translation;

-- ============================================================
-- 4) Store Missing Values Checks (NULL/EMPTY) - including numeric columns
-- ============================================================

/* ---- raw_orders ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_orders', 'missing_order_id',
       SUM(order_id IS NULL OR order_id = '')
FROM raw_orders;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_orders', 'missing_customer_id',
       SUM(customer_id IS NULL OR customer_id = '')
FROM raw_orders;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_orders', 'missing_order_status',
       SUM(order_status IS NULL OR order_status = '')
FROM raw_orders;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_orders', 'missing_purchase_ts',
       SUM(order_purchase_timestamp IS NULL OR order_purchase_timestamp = '')
FROM raw_orders;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_orders', 'missing_estimated_delivery_ts',
       SUM(order_estimated_delivery_date IS NULL OR order_estimated_delivery_date = '')
FROM raw_orders;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_orders', 'missing_delivered_customer_ts',
       SUM(order_delivered_customer_date IS NULL OR order_delivered_customer_date = '')
FROM raw_orders;

/* ---- raw_customers (numeric zip prefix) ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_customers', 'missing_customer_id',
       SUM(customer_id IS NULL OR customer_id = '')
FROM raw_customers;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_customers', 'missing_customer_unique_id',
       SUM(customer_unique_id IS NULL OR customer_unique_id = '')
FROM raw_customers;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_customers', 'missing_customer_city',
       SUM(customer_city IS NULL OR customer_city = '')
FROM raw_customers;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_customers', 'missing_customer_state',
       SUM(customer_state IS NULL OR customer_state = '')
FROM raw_customers;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_customers', 'missing_customer_zip_prefix',
       SUM(customer_zip_code_prefix IS NULL)
FROM raw_customers;

/* ---- raw_order_items (numeric: order_item_id, price, freight_value) ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_items', 'missing_order_id',
       SUM(order_id IS NULL OR order_id = '')
FROM raw_order_items;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_items', 'missing_product_id',
       SUM(product_id IS NULL OR product_id = '')
FROM raw_order_items;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_items', 'missing_seller_id',
       SUM(seller_id IS NULL OR seller_id = '')
FROM raw_order_items;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_items', 'missing_order_item_id',
       SUM(order_item_id IS NULL)
FROM raw_order_items;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_items', 'missing_price',
       SUM(price IS NULL)
FROM raw_order_items;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_items', 'missing_freight_value',
       SUM(freight_value IS NULL)
FROM raw_order_items;

/* ---- raw_order_payments (numeric: sequential, installments, value) ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_payments', 'missing_order_id',
       SUM(order_id IS NULL OR order_id = '')
FROM raw_order_payments;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_payments', 'missing_payment_type',
       SUM(payment_type IS NULL OR payment_type = '')
FROM raw_order_payments;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_payments', 'missing_payment_sequential',
       SUM(payment_sequential IS NULL)
FROM raw_order_payments;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_payments', 'missing_payment_installments',
       SUM(payment_installments IS NULL)
FROM raw_order_payments;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_payments', 'missing_payment_value',
       SUM(payment_value IS NULL)
FROM raw_order_payments;

/* ---- raw_order_reviews (numeric review_score) ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_reviews', 'missing_review_id',
       SUM(review_id IS NULL OR review_id = '')
FROM raw_order_reviews;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_reviews', 'missing_order_id',
       SUM(order_id IS NULL OR order_id = '')
FROM raw_order_reviews;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_order_reviews', 'missing_review_score',
       SUM(review_score IS NULL)
FROM raw_order_reviews;

/* ---- raw_products (numeric attributes) ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_products', 'missing_product_id',
       SUM(product_id IS NULL OR product_id = '')
FROM raw_products;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_products', 'missing_product_category_name',
       SUM(product_category_name IS NULL OR product_category_name = '')
FROM raw_products;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_products', 'missing_product_weight_g',
       SUM(product_weight_g IS NULL)
FROM raw_products;

/* ---- raw_sellers (numeric zip prefix) ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_sellers', 'missing_seller_id',
       SUM(seller_id IS NULL OR seller_id = '')
FROM raw_sellers;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_sellers', 'missing_seller_zip_prefix',
       SUM(seller_zip_code_prefix IS NULL)
FROM raw_sellers;

/* ---- raw_geolocation (numeric lat/lng + zip prefix) ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_geolocation', 'missing_geo_zip_prefix',
       SUM(geolocation_zip_code_prefix IS NULL)
FROM raw_geolocation;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_geolocation', 'missing_geo_lat',
       SUM(geolocation_lat IS NULL)
FROM raw_geolocation;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_geolocation', 'missing_geo_lng',
       SUM(geolocation_lng IS NULL)
FROM raw_geolocation;

/* ---- raw_category_translation ---- */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_category_translation', 'missing_pt_category',
       SUM(product_category_name IS NULL OR product_category_name = '')
FROM raw_category_translation;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'missing', 'raw_category_translation', 'missing_en_category',
       SUM(product_category_name_english IS NULL OR product_category_name_english = '')
FROM raw_category_translation;

-- ============================================================
-- 5) Store Duplicate Checks (store COUNTS, not row lists)
--    This avoids huge outputs and is safer for Workbench.
-- ============================================================

/* 5.1 Unique-key duplicates: raw_orders.order_id */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_unique', 'raw_orders', 'duplicate_order_id_groups',
       COUNT(*)
FROM (
  SELECT order_id
  FROM raw_orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
) d;

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_unique', 'raw_orders', 'duplicate_order_id_extra_rows',
       COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT order_id, COUNT(*) AS cnt
  FROM raw_orders
  GROUP BY order_id
  HAVING COUNT(*) > 1
) d;

/* 5.2 Unique-key duplicates: raw_products.product_id */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_unique', 'raw_products', 'duplicate_product_id_groups',
       COUNT(*)
FROM (
  SELECT product_id
  FROM raw_products
  GROUP BY product_id
  HAVING COUNT(*) > 1
) d;

/* 5.3 Composite duplicates: raw_order_items(order_id, order_item_id) */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_composite', 'raw_order_items', 'duplicate_order_item_key_groups',
       COUNT(*)
FROM (
  SELECT order_id, order_item_id
  FROM raw_order_items
  GROUP BY order_id, order_item_id
  HAVING COUNT(*) > 1
) d;

/* 5.4 Composite duplicates: raw_order_payments(order_id, payment_sequential) */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_composite', 'raw_order_payments', 'duplicate_payment_key_groups',
       COUNT(*)
FROM (
  SELECT order_id, payment_sequential
  FROM raw_order_payments
  GROUP BY order_id, payment_sequential
  HAVING COUNT(*) > 1
) d;

-- ============================================================
-- 6) Full-row duplicates for SMALL/MEDIUM tables (store counts)
-- ============================================================

/* Full-row duplicates: raw_customers */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_fullrow', 'raw_customers', 'duplicate_full_row_groups',
       COUNT(*)
FROM (
  SELECT
    customer_id, customer_unique_id, customer_zip_code_prefix,
    customer_city, customer_state
  FROM raw_customers
  GROUP BY
    customer_id, customer_unique_id, customer_zip_code_prefix,
    customer_city, customer_state
  HAVING COUNT(*) > 1
) d;

/* Full-row duplicates: raw_orders */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_fullrow', 'raw_orders', 'duplicate_full_row_groups',
       COUNT(*)
FROM (
  SELECT
    order_id, customer_id, order_status,
    order_purchase_timestamp, order_approved_at,
    order_delivered_carrier_date, order_delivered_customer_date,
    order_estimated_delivery_date
  FROM raw_orders
  GROUP BY
    order_id, customer_id, order_status,
    order_purchase_timestamp, order_approved_at,
    order_delivered_carrier_date, order_delivered_customer_date,
    order_estimated_delivery_date
  HAVING COUNT(*) > 1
) d;

/* Full-row duplicates: raw_order_payments */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_fullrow', 'raw_order_payments', 'duplicate_full_row_groups',
       COUNT(*)
FROM (
  SELECT
    order_id, payment_sequential, payment_type,
    payment_installments, payment_value
  FROM raw_order_payments
  GROUP BY
    order_id, payment_sequential, payment_type,
    payment_installments, payment_value
  HAVING COUNT(*) > 1
) d;

/* Full-row duplicates: raw_products */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_fullrow', 'raw_products', 'duplicate_full_row_groups',
       COUNT(*)
FROM (
  SELECT
    product_id, product_category_name,
    product_name_lenght, product_description_lenght,
    product_photos_qty, product_weight_g,
    product_length_cm, product_height_cm, product_width_cm
  FROM raw_products
  GROUP BY
    product_id, product_category_name,
    product_name_lenght, product_description_lenght,
    product_photos_qty, product_weight_g,
    product_length_cm, product_height_cm, product_width_cm
  HAVING COUNT(*) > 1
) d;

/* Full-row duplicates: raw_sellers */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_fullrow', 'raw_sellers', 'duplicate_full_row_groups',
       COUNT(*)
FROM (
  SELECT
    seller_id, seller_zip_code_prefix, seller_city, seller_state
  FROM raw_sellers
  GROUP BY
    seller_id, seller_zip_code_prefix, seller_city, seller_state
  HAVING COUNT(*) > 1
) d;

/* Full-row duplicates: raw_category_translation */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_fullrow', 'raw_category_translation', 'duplicate_full_row_groups',
       COUNT(*)
FROM (
  SELECT
    product_category_name, product_category_name_english
  FROM raw_category_translation
  GROUP BY
    product_category_name, product_category_name_english
  HAVING COUNT(*) > 1
) d;

-- ============================================================
-- 7) Geolocation special checks (safe metrics) - store counts only
-- ============================================================

/* Geolocation: zip prefix repeats are expected, so we store only informational metrics. */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'geo_info', 'raw_geolocation', 'zip_prefix_with_multiple_rows',
       COUNT(*)
FROM (
  SELECT geolocation_zip_code_prefix
  FROM raw_geolocation
  GROUP BY geolocation_zip_code_prefix
  HAVING COUNT(*) > 1
) d;

/* Geolocation: city/state inconsistency per zip prefix (quality signal). */
INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'geo_info', 'raw_geolocation', 'zip_prefix_city_state_inconsistency',
       COUNT(*)
FROM (
  SELECT geolocation_zip_code_prefix
  FROM raw_geolocation
  GROUP BY geolocation_zip_code_prefix
  HAVING COUNT(DISTINCT geolocation_city) > 1
      OR COUNT(DISTINCT geolocation_state) > 1
) d;

/*
OPTIONAL (HEAVY): Full-row duplicate groups for raw_geolocation
- Can be expensive and may timeout in Workbench (Error 2013).
- Run only after increasing Workbench timeout and/or creating an index.

CREATE INDEX idx_geo_full
ON raw_geolocation(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

INSERT INTO dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'dup_fullrow', 'raw_geolocation', 'duplicate_full_row_groups',
       COUNT(*)
FROM (
  SELECT
    geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
    geolocation_city, geolocation_state
  FROM raw_geolocation
  GROUP BY
    geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
    geolocation_city, geolocation_state
  HAVING COUNT(*) > 1
) d;
*/

-- ============================================================
-- 8) View stored results for THIS run_id
-- ============================================================

SELECT run_id, run_stage, notes, started_at
FROM dq_runs
WHERE run_id = (@run_id COLLATE utf8mb4_unicode_ci);

SELECT check_group, table_name, metric_name, metric_value, created_at
FROM dq_results
WHERE run_id = (@run_id COLLATE utf8mb4_unicode_ci)
ORDER BY check_group, table_name, metric_name;
