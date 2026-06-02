/* ============================================================
   PK Candidate Checks (NULL + Duplicates) - FIXED SCRIPT
   Schema: olist360

   Fix for Error 1136:
   - Every INSERT explicitly specifies the target column list:
     (run_id, stage_name, table_name, key_name, check_name, metric_value)

   What this script does:
   1) Creates results_pk_candidate_checks if it doesn't exist
   2) Generates a run_id for traceability
   3) Inserts:
        - missing_key (NULL/empty)
        - duplicate_key_groups
        - duplicate_extra_rows
   4) Displays stored results for this run_id
   ============================================================ */

USE olist360;

-- 1) Create the standalone results table (safe to re-run)
CREATE TABLE IF NOT EXISTS results_pk_candidate_checks (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,

  run_id VARCHAR(40) NOT NULL,
  stage_name VARCHAR(60) NOT NULL,

  table_name VARCHAR(80) NOT NULL,
  key_name VARCHAR(120) NOT NULL,        -- e.g., 'order_id' or '(order_id, order_item_id)'
  check_name VARCHAR(120) NOT NULL,      -- e.g., 'missing_key', 'duplicate_key_groups', 'duplicate_extra_rows'
  metric_value BIGINT NOT NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_run (run_id),
  INDEX idx_table (table_name)
);

-- 2) Create a run id + stage label
SET @run_id = CONCAT('RUN_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'));
SET @stage  = 'PHASE1_PK_CANDIDATES_CHECK';

-- ============================================================
-- 3) MISSING (NULL/EMPTY) checks (Inserted in ONE statement)
-- ============================================================
INSERT INTO results_pk_candidate_checks
(run_id, stage_name, table_name, key_name, check_name, metric_value)

-- core_orders(order_id)
SELECT @run_id, @stage, 'core_orders', 'order_id', 'missing_key',
       SUM(order_id IS NULL OR order_id = '')
FROM core_orders

UNION ALL
-- core_customers(customer_id)
SELECT @run_id, @stage, 'core_customers', 'customer_id', 'missing_key',
       SUM(customer_id IS NULL OR customer_id = '')
FROM core_customers

UNION ALL
-- core_products(product_id)
SELECT @run_id, @stage, 'core_products', 'product_id', 'missing_key',
       SUM(product_id IS NULL OR product_id = '')
FROM core_products

UNION ALL
-- core_sellers(seller_id)
SELECT @run_id, @stage, 'core_sellers', 'seller_id', 'missing_key',
       SUM(seller_id IS NULL OR seller_id = '')
FROM core_sellers

UNION ALL
-- core_reviews(review_id)
SELECT @run_id, @stage, 'core_reviews', 'review_id', 'missing_key',
       SUM(review_id IS NULL OR review_id = '')
FROM core_reviews

UNION ALL
-- core_order_items(order_id, order_item_id) composite
SELECT @run_id, @stage, 'core_order_items', '(order_id, order_item_id)', 'missing_key',
       SUM(order_id IS NULL OR order_id = '') + SUM(order_item_id IS NULL)
FROM core_order_items

UNION ALL
-- core_payments(order_id, payment_sequential) composite
SELECT @run_id, @stage, 'core_payments', '(order_id, payment_sequential)', 'missing_key',
       SUM(order_id IS NULL OR order_id = '') + SUM(payment_sequential IS NULL)
FROM core_payments

UNION ALL
-- ref_category_translation(product_category_name)
SELECT @run_id, @stage, 'ref_category_translation', 'product_category_name', 'missing_key',
       SUM(product_category_name IS NULL OR product_category_name = '')
FROM ref_category_translation
;

-- ============================================================
-- 4) DUPLICATE checks: duplicate_key_groups + duplicate_extra_rows
--    (Each INSERT explicitly lists the target columns)
-- ============================================================

/* core_orders(order_id) */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_orders', 'order_id', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT order_id FROM core_orders GROUP BY order_id HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_orders', 'order_id', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT order_id, COUNT(*) AS cnt FROM core_orders GROUP BY order_id HAVING COUNT(*) > 1
) d;

/* core_customers(customer_id) */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_customers', 'customer_id', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT customer_id FROM core_customers GROUP BY customer_id HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_customers', 'customer_id', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT customer_id, COUNT(*) AS cnt FROM core_customers GROUP BY customer_id HAVING COUNT(*) > 1
) d;

/* core_products(product_id) */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_products', 'product_id', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT product_id FROM core_products GROUP BY product_id HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_products', 'product_id', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT product_id, COUNT(*) AS cnt FROM core_products GROUP BY product_id HAVING COUNT(*) > 1
) d;

/* core_sellers(seller_id) */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_sellers', 'seller_id', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT seller_id FROM core_sellers GROUP BY seller_id HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_sellers', 'seller_id', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT seller_id, COUNT(*) AS cnt FROM core_sellers GROUP BY seller_id HAVING COUNT(*) > 1
) d;

/* core_reviews(review_id) */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_reviews', 'review_id', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT review_id FROM core_reviews GROUP BY review_id HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_reviews', 'review_id', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT review_id, COUNT(*) AS cnt FROM core_reviews GROUP BY review_id HAVING COUNT(*) > 1
) d;

/* core_order_items(order_id, order_item_id) composite */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_order_items', '(order_id, order_item_id)', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT order_id, order_item_id
  FROM core_order_items
  GROUP BY order_id, order_item_id
  HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_order_items', '(order_id, order_item_id)', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT order_id, order_item_id, COUNT(*) AS cnt
  FROM core_order_items
  GROUP BY order_id, order_item_id
  HAVING COUNT(*) > 1
) d;

/* core_payments(order_id, payment_sequential) composite */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_payments', '(order_id, payment_sequential)', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT order_id, payment_sequential
  FROM core_payments
  GROUP BY order_id, payment_sequential
  HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'core_payments', '(order_id, payment_sequential)', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT order_id, payment_sequential, COUNT(*) AS cnt
  FROM core_payments
  GROUP BY order_id, payment_sequential
  HAVING COUNT(*) > 1
) d;

/* ref_category_translation(product_category_name) */
INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'ref_category_translation', 'product_category_name', 'duplicate_key_groups', COUNT(*)
FROM (
  SELECT product_category_name
  FROM ref_category_translation
  GROUP BY product_category_name
  HAVING COUNT(*) > 1
) d;

INSERT INTO results_pk_candidate_checks (run_id, stage_name, table_name, key_name, check_name, metric_value)
SELECT @run_id, @stage, 'ref_category_translation', 'product_category_name', 'duplicate_extra_rows', COALESCE(SUM(cnt - 1), 0)
FROM (
  SELECT product_category_name, COUNT(*) AS cnt
  FROM ref_category_translation
  GROUP BY product_category_name
  HAVING COUNT(*) > 1
) d;

-- ============================================================
-- 5) View stored results for this run_id
-- ============================================================
SELECT *
FROM results_pk_candidate_checks
WHERE run_id = @run_id
ORDER BY table_name, check_name;