/* ============================================================================
   Olist 360 – Data Quality Framework
   Check Group : Data Type Standardization

   Purpose:
     - Generate a unique run_id dynamically
     - Register a new Data Quality run
     - Validate timestamp columns using pattern-safe logic
     - Validate numeric columns
     - Store results in a centralized DQ results table

   Supported Timestamp Formats:
     - ISO : YYYY-MM-DD HH:MI:SS
     - US  : MM/DD/YYYY H:MI

   Notes:
     - ZERO MySQL warnings
     - No deletes
     - No source data modification
============================================================================ */

USE olist360;

-- ============================================================================
-- PART 0: Generate Dynamic Run ID
-- ============================================================================

SET @run_id := CONCAT('RUN_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'));

-- ============================================================================
-- PART 1: Register DQ Run
-- ============================================================================

INSERT INTO results_dq_runs (run_id, run_stage, notes)
VALUES
(
  @run_id,
  'DATA_TYPE_STANDARDIZATION',
  'Timestamp & numeric validation using pattern-safe logic'
);

-- ============================================================================
-- PART 2: Insert DQ Results
-- ============================================================================

INSERT INTO results_dq_results
(run_id, check_group, table_name, metric_name, metric_value)

-- ============================================================================
-- PART 2.1: Timestamp Validity Checks (NO WARNINGS)
-- Object:
--   Count timestamps that do NOT match any supported format
-- ============================================================================

SELECT
  @run_id,
  'DATA_TYPE_STANDARDIZATION',
  'core_orders',
  'order_purchase_timestamp_invalid_timestamp',
  COUNT(*)
FROM core_orders
WHERE order_purchase_timestamp IS NOT NULL
  AND order_purchase_timestamp <> ''
  AND order_purchase_timestamp NOT REGEXP
      '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
  AND order_purchase_timestamp NOT REGEXP
      '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'

UNION ALL
SELECT
  @run_id,
  'DATA_TYPE_STANDARDIZATION',
  'core_orders',
  'order_approved_at_invalid_timestamp',
  COUNT(*)
FROM core_orders
WHERE order_approved_at IS NOT NULL
  AND order_approved_at <> ''
  AND order_approved_at NOT REGEXP
      '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
  AND order_approved_at NOT REGEXP
      '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'

UNION ALL
SELECT
  @run_id,
  'DATA_TYPE_STANDARDIZATION',
  'core_reviews',
  'review_creation_date_invalid_timestamp',
  COUNT(*)
FROM core_reviews
WHERE review_creation_date IS NOT NULL
  AND review_creation_date <> ''
  AND review_creation_date NOT REGEXP
      '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
  AND review_creation_date NOT REGEXP
      '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4} [0-9]{1,2}:[0-9]{2}$'

-- ============================================================================
-- PART 2.2: Numeric Validation Checks
-- ============================================================================

UNION ALL
SELECT
  @run_id,
  'DATA_TYPE_STANDARDIZATION',
  'core_order_items',
  'price_invalid_numeric',
  COUNT(*)
FROM core_order_items
WHERE price IS NOT NULL
  AND price REGEXP '[^0-9\\.]'

UNION ALL
SELECT
  @run_id,
  'DATA_TYPE_STANDARDIZATION',
  'core_payments',
  'payment_installments_invalid_numeric',
  COUNT(*)
FROM core_payments
WHERE payment_installments IS NOT NULL
  AND payment_installments REGEXP '[^0-9]';