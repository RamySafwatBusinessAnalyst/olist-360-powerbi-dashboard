/* ============================================================
   PHASE 2: Orphan Checks & Referential Integrity Validation
   FINAL FIX: Safe index creation (no duplicate key errors)
   Schema: olist360
   ============================================================ */

USE olist360;

-- ------------------------------------------------------------
-- 0) Register a new DQ run
-- ------------------------------------------------------------
SET @run_id = CONCAT('RUN_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'));
SET @stage  = 'PHASE_2_ORPHAN_CHECKS';
SET @notes  = 'Optimized orphan checks with safe index creation';

INSERT INTO results_dq_runs (run_id, run_stage, notes)
VALUES (@run_id, @stage, @notes);

-- ------------------------------------------------------------
-- 1) SAFE INDEX CREATION (only if not exists)
-- ------------------------------------------------------------

/* Helper pattern:
   - Check information_schema.statistics
   - Create index only if missing
*/

-- core_orders.customer_id
SET @idx := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema='olist360'
    AND table_name='core_orders'
    AND index_name='idx_orders_customer_id'
);
SET @sql := IF(@idx=0,
  'CREATE INDEX idx_orders_customer_id ON core_orders(customer_id);',
  'SELECT ''idx_orders_customer_id already exists'';'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- core_order_items.order_id
SET @idx := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema='olist360'
    AND table_name='core_order_items'
    AND index_name='idx_items_order_id'
);
SET @sql := IF(@idx=0,
  'CREATE INDEX idx_items_order_id ON core_order_items(order_id);',
  'SELECT ''idx_items_order_id already exists'';'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- core_order_items.product_id
SET @idx := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema='olist360'
    AND table_name='core_order_items'
    AND index_name='idx_items_product_id'
);
SET @sql := IF(@idx=0,
  'CREATE INDEX idx_items_product_id ON core_order_items(product_id);',
  'SELECT ''idx_items_product_id already exists'';'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- core_order_items.seller_id
SET @idx := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema='olist360'
    AND table_name='core_order_items'
    AND index_name='idx_items_seller_id'
);
SET @sql := IF(@idx=0,
  'CREATE INDEX idx_items_seller_id ON core_order_items(seller_id);',
  'SELECT ''idx_items_seller_id already exists'';'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- core_payments.order_id
SET @idx := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema='olist360'
    AND table_name='core_payments'
    AND index_name='idx_payments_order_id'
);
SET @sql := IF(@idx=0,
  'CREATE INDEX idx_payments_order_id ON core_payments(order_id);',
  'SELECT ''idx_payments_order_id already exists'';'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- core_reviews.order_id
SET @idx := (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema='olist360'
    AND table_name='core_reviews'
    AND index_name='idx_reviews_order_id'
);
SET @sql := IF(@idx=0,
  'CREATE INDEX idx_reviews_order_id ON core_reviews(order_id);',
  'SELECT ''idx_reviews_order_id already exists'';'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ------------------------------------------------------------
-- 2) Orphan Checks (BINARY-safe, fast)
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS results_orphan_checks (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  run_id VARCHAR(40) NOT NULL,
  child_table VARCHAR(80) NOT NULL,
  parent_table VARCHAR(80) NOT NULL,
  child_column VARCHAR(80) NOT NULL,
  parent_column VARCHAR(80) NOT NULL,
  orphan_count BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_run (run_id)
);

-- Example orphan check (repeat pattern as needed)
INSERT INTO results_orphan_checks
(run_id, child_table, parent_table, child_column, parent_column, orphan_count)
SELECT
  @run_id,'core_payments','core_orders','order_id','order_id',COUNT(*)
FROM core_payments p
WHERE p.order_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM core_orders o
    WHERE BINARY o.order_id = BINARY p.order_id
  );

-- ------------------------------------------------------------
-- 3) Summary results
-- ------------------------------------------------------------
INSERT INTO results_dq_results
(run_id, check_group, table_name, metric_name, metric_value)
SELECT
  @run_id,'ORPHAN_CHECKS','ALL','total_orphan_rows',SUM(orphan_count)
FROM results_orphan_checks
WHERE run_id=@run_id;