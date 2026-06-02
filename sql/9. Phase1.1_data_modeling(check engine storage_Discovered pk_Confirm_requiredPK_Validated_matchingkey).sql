/* ============================================================
   PHASE 1: Prerequisites Check (Olist 360)
   Schema: olist360
   Tables (your naming):
     core_customers, core_order_items, core_orders, core_payments,
     core_products, core_reviews, core_sellers,
     ref_category_translation, ref_geolocation

   What this script does (no FK creation yet):
   1) Confirm storage engine is InnoDB for core_/ref_ tables
   2) List all columns for core_/ref_ tables (inventory)
   3) Discover "key-like" columns automatically (pattern-based)
   4) Confirm required key columns exist (explicit list)
   5) Validate data type compatibility for intended FK pairs
   ============================================================ */

USE olist360;

-- ============================================================
-- 0) Settings
-- ============================================================
SET @schema_name = 'olist360';

-- ============================================================
-- 1) ENGINE CHECK (Foreign keys require InnoDB)
--    This checks ALL tables that start with core_ or ref_
-- ============================================================
SELECT table_name, engine
FROM information_schema.tables
WHERE table_schema = @schema_name
  AND (table_name LIKE 'core\_%' ESCAPE '\\' OR table_name LIKE 'ref\_%' ESCAPE '\\')
ORDER BY table_name;

-- OPTIONAL: generate ALTER statements for any non-InnoDB table (DO NOT EXECUTE automatically)
SELECT GROUP_CONCAT(CONCAT('ALTER TABLE `', table_schema, '`.`', table_name, '` ENGINE=InnoDB') SEPARATOR ';\n')
INTO @sql_convert_to_innodb
FROM information_schema.tables
WHERE table_schema = @schema_name
  AND (table_name LIKE 'core\_%' ESCAPE '\\' OR table_name LIKE 'ref\_%' ESCAPE '\\')
  AND engine <> 'InnoDB'; 
-- Inspect generated conversion SQL (if NULL => everything is already InnoDB)
SELECT @sql_convert_to_innodb AS generated_innodb_conversion_sql; 

-- If you want to execute it, uncomment the 3 lines below:
-- PREPARE stmt FROM @sql_convert_to_innodb;
-- EXECUTE stmt;
-- DEALLOCATE PREPARE stmt;


-- ============================================================
-- 2) FULL COLUMN INVENTORY (all columns in all core_/ref_ tables)
--    Useful as a "data dictionary" reference
-- ============================================================
SELECT
  table_name,
  ordinal_position,
  column_name,
  data_type,
  character_maximum_length,
  is_nullable
FROM information_schema.columns
WHERE table_schema = @schema_name
  AND (table_name LIKE 'core\_%' ESCAPE '\\' OR table_name LIKE 'ref\_%' ESCAPE '\\')
ORDER BY table_name, ordinal_position;


-- ============================================================
-- 3) AUTO-DISCOVER KEY-LIKE COLUMNS (no manual list)
--    This finds likely relationship keys based on naming patterns.
-- ============================================================
SELECT
  table_name,
  column_name,
  data_type,
  character_maximum_length
FROM information_schema.columns
WHERE table_schema = @schema_name
  AND (table_name LIKE 'core\_%' ESCAPE '\\' OR table_name LIKE 'ref\_%' ESCAPE '\\')
  AND (
    column_name LIKE '%\_id' ESCAPE '\\'
    OR column_name LIKE '%zip_code_prefix%'
    OR column_name LIKE '%category_name%'
    OR column_name LIKE '%sequential%'
    OR column_name LIKE '%item_id%'
  )
ORDER BY table_name, column_name;


-- ============================================================
-- 4) EXPLICIT REQUIRED KEY COLUMNS CHECK (matches your earlier list)
--    Confirms key columns exist (relationship keys)
-- ============================================================
SELECT table_name, column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = @schema_name
  AND table_name IN (
    'core_customers','core_order_items','core_orders','core_payments',
    'core_products','core_reviews','core_sellers',
    'ref_category_translation','ref_geolocation'
  )
  AND column_name IN (
    'order_id','customer_id','customer_unique_id',
    'order_item_id','product_id','seller_id',
    'payment_sequential',
    'review_id',
    'product_category_name','product_category_name_english',
    'customer_zip_code_prefix','seller_zip_code_prefix',
    'geolocation_zip_code_prefix'
  )
ORDER BY table_name, column_name;
