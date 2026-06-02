/* ============================================================
   PK Presence Logging (Standalone Results Table)
   Schema: olist360

   What this script does:
   1) Ensures we are using the correct database (USE olist360)
   2) Creates a standalone table to store PK presence results
   3) Generates a unique run_id for traceability
   4) Inserts PK presence (0/1) for the selected tables
   5) Displays the stored results for the same run_id

   How to use:
   - Copy/paste into MySQL Workbench and run it as one script.
   ============================================================ */

-- 1) Use the correct database
USE olist360;

-- 2) Create a standalone table to store PK status results
--    (Run once; CREATE TABLE IF NOT EXISTS makes it safe to re-run.)
CREATE TABLE IF NOT EXISTS results_pk_status (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,

  -- Identifies this execution so you can compare across stages/runs
  run_id VARCHAR(40) NOT NULL,

  -- Optional label for the stage (e.g., PHASE1_PK_PRESENCE)
  stage_name VARCHAR(60) NOT NULL,

  -- The table we checked
  table_name VARCHAR(80) NOT NULL,

  -- 1 = has PRIMARY KEY, 0 = no PRIMARY KEY
  has_primary_key TINYINT NOT NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_run (run_id),
  INDEX idx_table (table_name)
);

-- 3) Create a unique run id (timestamp-based) and a stage label
SET @run_id = CONCAT('RUN_', DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'));
SET @stage  = 'PHASE1_PK_PRESENCE';

-- 4) Insert PK presence results (0/1) into the standalone table
INSERT INTO results_pk_status (run_id, stage_name, table_name, has_primary_key)
SELECT
  @run_id AS run_id,
  @stage  AS stage_name,
  t.table_name,
  MAX(CASE WHEN s.index_name = 'PRIMARY' THEN 1 ELSE 0 END) AS has_primary_key
FROM information_schema.tables t
LEFT JOIN information_schema.statistics s
  ON s.table_schema = t.table_schema
 AND s.table_name   = t.table_name
WHERE t.table_schema = 'olist360'
  AND t.table_name IN (
    'core_orders','core_customers','core_products','core_sellers',
    'core_order_items','core_payments','core_reviews',
    'ref_category_translation'
  )
GROUP BY t.table_name
ORDER BY t.table_name;

-- 5) Immediately view what was stored for this run_id
SELECT *
FROM results_pk_status
WHERE run_id = @run_id
ORDER BY table_name;