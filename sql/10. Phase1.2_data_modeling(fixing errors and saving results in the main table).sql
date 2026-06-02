/* ============================================================
   PHASE 1: FK PLAN VALIDATION (Store Summary + Details)
   FIXED for:
     - Error 1267 (Illegal mix of collations)
     - Error 1253 (Collation not valid for character set 'utf8')
   Approach:
     - Use BINARY comparisons in joins against INFORMATION_SCHEMA
       to avoid collation/charset conflicts entirely. [4](https://www.kaggle.com/datasets/yashrajbargal/brazilian-e-commerce-customers-dataset-by-olist)[2](https://www.youtube.com/watch?v=Ce5lW5hcjxk)

   Schema: olist360
   Logging tables (your schema):
     results_dq_runs(run_id, run_stage, notes, started_at)
     results_dq_results(id, run_id, check_group, table_name, metric_name, metric_value, created_at)
   ============================================================ */

USE olist360;

-- ------------------------------------------------------------
-- 1) Create details table (run once)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS results_dq_fk_plan_details (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  run_id VARCHAR(40) NOT NULL,

  child_table  VARCHAR(64) NOT NULL,
  child_col    VARCHAR(64) NOT NULL,
  parent_table VARCHAR(64) NOT NULL,
  parent_col   VARCHAR(64) NOT NULL,

  child_type VARCHAR(64),
  child_len  INT,
  parent_type VARCHAR(64),
  parent_len  INT,

  status VARCHAR(60) NOT NULL,  -- OK or FAIL_*
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_run (run_id),
  INDEX idx_status (status)
);

-- ------------------------------------------------------------
-- 2) Create a new DQ run
-- ------------------------------------------------------------
SET @run_id    = CONCAT('RUN_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'));
SET @run_stage = 'PHASE_1_FK_PLAN_VALIDATION';
SET @notes     = 'Validate FK plan (existence + type/length compatibility) before creating Foreign Keys';

INSERT INTO results_dq_runs (run_id, run_stage, notes)
VALUES (@run_id, @run_stage, @notes);

-- ------------------------------------------------------------
-- 3) Build FK plan (edit if your columns differ)
-- ------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS tmp_fk_plan;
CREATE TEMPORARY TABLE tmp_fk_plan (
  child_table  VARCHAR(64),
  child_col    VARCHAR(64),
  parent_table VARCHAR(64),
  parent_col   VARCHAR(64)
);

INSERT INTO tmp_fk_plan (child_table, child_col, parent_table, parent_col) VALUES
('core_orders',      'customer_id',            'core_customers',           'customer_id'),
('core_order_items', 'order_id',               'core_orders',              'order_id'),
('core_order_items', 'product_id',             'core_products',            'product_id'),
('core_order_items', 'seller_id',              'core_sellers',             'seller_id'),
('core_payments',    'order_id',               'core_orders',              'order_id'),
('core_reviews',     'order_id',               'core_orders',              'order_id'),
-- Optional FK (enforce only if you want):
('core_products',    'product_category_name',  'ref_category_translation', 'product_category_name');

-- ------------------------------------------------------------
-- 4) Validate plan -> tmp_fk_validation
--    KEY FIX: Use BINARY comparisons instead of COLLATE. [4](https://www.kaggle.com/datasets/yashrajbargal/brazilian-e-commerce-customers-dataset-by-olist)[2](https://www.youtube.com/watch?v=Ce5lW5hcjxk)
-- ------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS tmp_fk_validation;

CREATE TEMPORARY TABLE tmp_fk_validation AS
SELECT
  p.child_table,
  p.child_col,
  cc.data_type AS child_type,
  cc.character_maximum_length AS child_len,
  p.parent_table,
  p.parent_col,
  pc.data_type AS parent_type,
  pc.character_maximum_length AS parent_len,
  CASE
    WHEN cc.column_name IS NULL THEN 'FAIL_MISSING_CHILD_COLUMN'
    WHEN pc.column_name IS NULL THEN 'FAIL_MISSING_PARENT_COLUMN'
    WHEN cc.data_type <> pc.data_type THEN 'FAIL_TYPE_MISMATCH'
    WHEN cc.data_type IN ('varchar','char')
         AND IFNULL(cc.character_maximum_length,-1) <> IFNULL(pc.character_maximum_length,-1)
         THEN 'FAIL_LENGTH_MISMATCH'
    ELSE 'OK'
  END AS status
FROM tmp_fk_plan p
LEFT JOIN information_schema.columns cc
  ON cc.table_schema = 'olist360'
 AND BINARY cc.table_name  = BINARY p.child_table
 AND BINARY cc.column_name = BINARY p.child_col
LEFT JOIN information_schema.columns pc
  ON pc.table_schema = 'olist360'
 AND BINARY pc.table_name  = BINARY p.parent_table
 AND BINARY pc.column_name = BINARY p.parent_col;

-- ------------------------------------------------------------
-- 5) Store SUMMARY metrics into results_dq_results
-- ------------------------------------------------------------
INSERT INTO results_dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'FK_PLAN_VALIDATION', 'ALL', 'fk_plan_total_relationships', COUNT(*)
FROM tmp_fk_validation;

INSERT INTO results_dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'FK_PLAN_VALIDATION', 'ALL', 'fk_plan_ok_relationships', SUM(status='OK')
FROM tmp_fk_validation;

INSERT INTO results_dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'FK_PLAN_VALIDATION', 'ALL', 'fk_plan_failed_relationships', SUM(status<>'OK')
FROM tmp_fk_validation;

INSERT INTO results_dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'FK_PLAN_VALIDATION', 'ALL', 'fk_plan_fail_missing_child', SUM(status='FAIL_MISSING_CHILD_COLUMN')
FROM tmp_fk_validation;

INSERT INTO results_dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'FK_PLAN_VALIDATION', 'ALL', 'fk_plan_fail_missing_parent', SUM(status='FAIL_MISSING_PARENT_COLUMN')
FROM tmp_fk_validation;

INSERT INTO results_dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'FK_PLAN_VALIDATION', 'ALL', 'fk_plan_fail_type_mismatch', SUM(status='FAIL_TYPE_MISMATCH')
FROM tmp_fk_validation;

INSERT INTO results_dq_results (run_id, check_group, table_name, metric_name, metric_value)
SELECT @run_id, 'FK_PLAN_VALIDATION', 'ALL', 'fk_plan_fail_length_mismatch', SUM(status='FAIL_LENGTH_MISMATCH')
FROM tmp_fk_validation;

-- ------------------------------------------------------------
-- 6) Store DETAILED rows into results_dq_fk_plan_details
-- ------------------------------------------------------------
INSERT INTO results_dq_fk_plan_details (
  run_id, child_table, child_col, parent_table, parent_col,
  child_type, child_len, parent_type, parent_len, status
)
SELECT
  @run_id,
  child_table, child_col, parent_table, parent_col,
  child_type, child_len, parent_type, parent_len, status
FROM tmp_fk_validation;

-- ------------------------------------------------------------
-- 7) Quick views (stored summary + failures)
-- ------------------------------------------------------------
SELECT *
FROM results_dq_runs
WHERE run_id = @run_id;

SELECT check_group, table_name, metric_name, metric_value, created_at
FROM results_dq_results
WHERE run_id = @run_id
  AND check_group = 'FK_PLAN_VALIDATION'
ORDER BY metric_name;

SELECT *
FROM results_dq_fk_plan_details
WHERE run_id = @run_id
  AND status <> 'OK'
ORDER BY child_table, child_col;