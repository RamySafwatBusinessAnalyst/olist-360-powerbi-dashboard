/* ============================================================================
   Olist 360 - Step 3: Data Quality Checks (Combined Script)
   Database: olist360

   Includes:
   A) Missing values checks (including numeric columns)
   B) Duplicate checks:
      - Unique key duplicates
      - Composite key duplicates
      - Full-row duplicates (exact duplicate rows)

   Notes:
   - We DO NOT run duplicates on numeric columns alone.
   - We run duplicates using correct uniqueness definitions (unique/composite/full row).
   - Geolocation full-row duplicates can be very expensive -> optional block provided.
   ============================================================================ */

USE olist360;

-- =============================================================================
-- 0) QUICK ROW COUNTS (Import confirmation)
-- =============================================================================
SELECT 'raw_orders' AS table_name, COUNT(*) AS row_count FROM raw_orders
UNION ALL SELECT 'raw_customers', COUNT(*) FROM raw_customers
UNION ALL SELECT 'raw_order_items', COUNT(*) FROM raw_order_items
UNION ALL SELECT 'raw_order_payments', COUNT(*) FROM raw_order_payments
UNION ALL SELECT 'raw_order_reviews', COUNT(*) FROM raw_order_reviews
UNION ALL SELECT 'raw_products', COUNT(*) FROM raw_products
UNION ALL SELECT 'raw_sellers', COUNT(*) FROM raw_sellers
UNION ALL SELECT 'raw_geolocation', COUNT(*) FROM raw_geolocation
UNION ALL SELECT 'raw_category_translation', COUNT(*) FROM raw_category_translation
ORDER BY table_name;

-- =============================================================================
-- A) MISSING VALUES CHECKS (NULL/EMPTY) — INCLUDING NUMERIC COLUMNS
-- =============================================================================

/* A1) raw_orders (critical identifiers + key timestamps) */
SELECT
  'raw_orders' AS table_name,
  SUM(order_id IS NULL OR order_id = '')            AS missing_order_id,
  SUM(customer_id IS NULL OR customer_id = '')      AS missing_customer_id,
  SUM(order_status IS NULL OR order_status = '')    AS missing_order_status,
  SUM(order_purchase_timestamp IS NULL OR order_purchase_timestamp = '') AS missing_purchase_ts,
  SUM(order_estimated_delivery_date IS NULL OR order_estimated_delivery_date = '') AS missing_estimated_delivery_ts,
  SUM(order_delivered_customer_date IS NULL OR order_delivered_customer_date = '') AS missing_delivered_customer_ts
FROM raw_orders;

/* A2) raw_customers (includes numeric zip prefix) */
SELECT
  'raw_customers' AS table_name,
  SUM(customer_id IS NULL OR customer_id = '')                 AS missing_customer_id,
  SUM(customer_unique_id IS NULL OR customer_unique_id = '')   AS missing_customer_unique_id,
  SUM(customer_city IS NULL OR customer_city = '')             AS missing_customer_city,
  SUM(customer_state IS NULL OR customer_state = '')           AS missing_customer_state,
  SUM(customer_zip_code_prefix IS NULL)                        AS missing_customer_zip_prefix
FROM raw_customers;

/* A3) raw_order_items (numeric columns: order_item_id, price, freight_value) */
SELECT
  'raw_order_items' AS table_name,
  SUM(order_id IS NULL OR order_id = '')     AS missing_order_id,
  SUM(product_id IS NULL OR product_id = '') AS missing_product_id,
  SUM(seller_id IS NULL OR seller_id = '')   AS missing_seller_id,
  SUM(order_item_id IS NULL)                 AS missing_order_item_id,
  SUM(price IS NULL)                         AS missing_price,
  SUM(freight_value IS NULL)                 AS missing_freight_value
FROM raw_order_items;

/* A4) raw_order_payments (numeric columns: sequential, installments, value) */
SELECT
  'raw_order_payments' AS table_name,
  SUM(order_id IS NULL OR order_id = '')          AS missing_order_id,
  SUM(payment_type IS NULL OR payment_type = '')  AS missing_payment_type,
  SUM(payment_sequential IS NULL)                 AS missing_payment_sequential,
  SUM(payment_installments IS NULL)               AS missing_payment_installments,
  SUM(payment_value IS NULL)                      AS missing_payment_value
FROM raw_order_payments;

/* A5) raw_order_reviews (numeric review_score + timestamps) */
SELECT
  'raw_order_reviews' AS table_name,
  SUM(review_id IS NULL OR review_id = '')        AS missing_review_id,
  SUM(order_id IS NULL OR order_id = '')          AS missing_order_id,
  SUM(review_score IS NULL)                       AS missing_review_score,
  SUM(review_creation_date IS NULL OR review_creation_date = '') AS missing_review_creation_date,
  SUM(review_answer_timestamp IS NULL OR review_answer_timestamp = '') AS missing_review_answer_timestamp
FROM raw_order_reviews;

/* A6) raw_products (numeric product attributes) */
SELECT
  'raw_products' AS table_name,
  SUM(product_id IS NULL OR product_id = '')             AS missing_product_id,
  SUM(product_category_name IS NULL OR product_category_name = '') AS missing_product_category_name,
  SUM(product_name_lenght IS NULL)        AS missing_product_name_length,
  SUM(product_description_lenght IS NULL) AS missing_product_description_length,
  SUM(product_photos_qty IS NULL)         AS missing_product_photos_qty,
  SUM(product_weight_g IS NULL)           AS missing_product_weight_g,
  SUM(product_length_cm IS NULL)          AS missing_product_length_cm,
  SUM(product_height_cm IS NULL)          AS missing_product_height_cm,
  SUM(product_width_cm IS NULL)           AS missing_product_width_cm
FROM raw_products;

/* A7) raw_sellers (includes numeric zip prefix) */
SELECT
  'raw_sellers' AS table_name,
  SUM(seller_id IS NULL OR seller_id = '')         AS missing_seller_id,
  SUM(seller_city IS NULL OR seller_city = '')     AS missing_seller_city,
  SUM(seller_state IS NULL OR seller_state = '')   AS missing_seller_state,
  SUM(seller_zip_code_prefix IS NULL)              AS missing_seller_zip_prefix
FROM raw_sellers;

/* A8) raw_geolocation (numeric lat/lng + zip prefix) */
SELECT
  'raw_geolocation' AS table_name,
  SUM(geolocation_zip_code_prefix IS NULL) AS missing_geo_zip_prefix,
  SUM(geolocation_lat IS NULL)             AS missing_geo_lat,
  SUM(geolocation_lng IS NULL)             AS missing_geo_lng,
  SUM(geolocation_city IS NULL OR geolocation_city = '')   AS missing_geo_city,
  SUM(geolocation_state IS NULL OR geolocation_state = '') AS missing_geo_state
FROM raw_geolocation;

/* A9) raw_category_translation (lookup: PT -> EN) */
SELECT
  'raw_category_translation' AS table_name,
  SUM(product_category_name IS NULL OR product_category_name = '') AS missing_pt_category,
  SUM(product_category_name_english IS NULL OR product_category_name_english = '') AS missing_en_category
FROM raw_category_translation;

-- =============================================================================
-- B) DUPLICATE CHECKS (Unique / Composite / Full-row)
-- =============================================================================

-- ------------------------------------------------------------
-- B1) UNIQUE KEY DUPLICATES (these should be 0)
-- ------------------------------------------------------------

/* raw_orders: order_id must be unique (order-level grain) */
SELECT order_id, COUNT(*) AS cnt
FROM raw_orders
GROUP BY order_id
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_products: product_id should be unique */
SELECT product_id, COUNT(*) AS cnt
FROM raw_products
GROUP BY product_id
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_sellers: seller_id should be unique */
SELECT seller_id, COUNT(*) AS cnt
FROM raw_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_order_reviews: review_id should be unique */
SELECT review_id, COUNT(*) AS cnt
FROM raw_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_category_translation: Portuguese category should be unique */
SELECT product_category_name, COUNT(*) AS cnt
FROM raw_category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_customers: customer_id is often unique; check if it repeats */
SELECT customer_id, COUNT(*) AS cnt
FROM raw_customers
GROUP BY customer_id
HAVING COUNT(*) > 1
LIMIT 50;

-- ------------------------------------------------------------
-- B2) COMPOSITE KEY DUPLICATES (these should be 0)
-- ------------------------------------------------------------

/* raw_order_items: (order_id, order_item_id) must be unique */
SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM raw_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_order_payments: (order_id, payment_sequential) must be unique */
SELECT order_id, payment_sequential, COUNT(*) AS cnt
FROM raw_order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_order_reviews: check multiple reviews per order_id (not always an error, but important to know) */
SELECT order_id, COUNT(*) AS reviews_per_order
FROM raw_order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1
LIMIT 50;

-- ------------------------------------------------------------
-- B3) FULL-ROW DUPLICATES (exact duplicate records)
-- These are redundant duplicates and can be safely deduplicated in cleaning.
-- ------------------------------------------------------------

/* raw_orders: exact duplicate rows */
SELECT
  order_id, customer_id, order_status,
  order_purchase_timestamp, order_approved_at,
  order_delivered_carrier_date, order_delivered_customer_date,
  order_estimated_delivery_date,
  COUNT(*) AS cnt
FROM raw_orders
GROUP BY
  order_id, customer_id, order_status,
  order_purchase_timestamp, order_approved_at,
  order_delivered_carrier_date, order_delivered_customer_date,
  order_estimated_delivery_date
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_customers: exact duplicate rows */
SELECT
  customer_id, customer_unique_id, customer_zip_code_prefix,
  customer_city, customer_state,
  COUNT(*) AS cnt
FROM raw_customers
GROUP BY
  customer_id, customer_unique_id, customer_zip_code_prefix,
  customer_city, customer_state
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_order_items: exact duplicate rows */
SELECT
  order_id, order_item_id, product_id, seller_id,
  shipping_limit_date, price, freight_value,
  COUNT(*) AS cnt
FROM raw_order_items
GROUP BY
  order_id, order_item_id, product_id, seller_id,
  shipping_limit_date, price, freight_value
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_order_payments: exact duplicate rows */
SELECT
  order_id, payment_sequential, payment_type,
  payment_installments, payment_value,
  COUNT(*) AS cnt
FROM raw_order_payments
GROUP BY
  order_id, payment_sequential, payment_type,
  payment_installments, payment_value
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_order_reviews: exact duplicate rows (including text fields) */
SELECT
  review_id, order_id, review_score,
  review_comment_title, review_comment_message,
  review_creation_date, review_answer_timestamp,
  COUNT(*) AS cnt
FROM raw_order_reviews
GROUP BY
  review_id, order_id, review_score,
  review_comment_title, review_comment_message,
  review_creation_date, review_answer_timestamp
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_products: exact duplicate rows */
SELECT
  product_id, product_category_name,
  product_name_lenght, product_description_lenght,
  product_photos_qty, product_weight_g,
  product_length_cm, product_height_cm, product_width_cm,
  COUNT(*) AS cnt
FROM raw_products
GROUP BY
  product_id, product_category_name,
  product_name_lenght, product_description_lenght,
  product_photos_qty, product_weight_g,
  product_length_cm, product_height_cm, product_width_cm
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_sellers: exact duplicate rows */
SELECT
  seller_id, seller_zip_code_prefix,
  seller_city, seller_state,
  COUNT(*) AS cnt
FROM raw_sellers
GROUP BY
  seller_id, seller_zip_code_prefix,
  seller_city, seller_state
HAVING COUNT(*) > 1
LIMIT 50;

/* raw_category_translation: exact duplicate rows */
SELECT
  product_category_name, product_category_name_english,
  COUNT(*) AS cnt
FROM raw_category_translation
GROUP BY
  product_category_name, product_category_name_english
HAVING COUNT(*) > 1
LIMIT 50;

-- ------------------------------------------------------------
-- B4) GEOLOCATION DUPLICATES (SPECIAL CASE)
-- Zip prefix repeats are expected by design.
-- Full-row duplicates check on geolocation is expensive and may timeout.
-- ------------------------------------------------------------

/* B4.1 Zip prefix repetition frequency (informational, NOT an error) */
SELECT
  geolocation_zip_code_prefix,
  COUNT(*) AS occurrences
FROM raw_geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;

/* B4.2 Optional: detect city/state inconsistency per zip prefix (quality signal) */
SELECT
  geolocation_zip_code_prefix,
  COUNT(DISTINCT geolocation_city)  AS distinct_cities,
  COUNT(DISTINCT geolocation_state) AS distinct_states
FROM raw_geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_city) > 1
    OR COUNT(DISTINCT geolocation_state) > 1
ORDER BY distinct_states DESC, distinct_cities DESC
LIMIT 50;

/*
B4.3 OPTIONAL (HEAVY): exact duplicate rows in raw_geolocation
- This can trigger Error 2013 in Workbench because the table is large.
- Only run after increasing Workbench timeout OR after creating a supporting index.

-- CREATE INDEX idx_geo_full
-- ON raw_geolocation(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

SELECT
  geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
  geolocation_city, geolocation_state,
  COUNT(*) AS cnt
FROM raw_geolocation
GROUP BY
  geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
  geolocation_city, geolocation_state
HAVING COUNT(*) > 1
LIMIT 50;
*/

-- =============================================================================
-- END OF SCRIPT
-- =============================================================================