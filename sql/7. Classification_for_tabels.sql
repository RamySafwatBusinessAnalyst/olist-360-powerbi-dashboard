/* ============================================================================
   Olist 360 – Step 4: Logical Organization using Naming Convention
   Database: olist360

   Goal:
   - Keep everything in ONE database
   - Organize tables by role using clear prefixes
   - No schemas, no metadata tables

   Prefixes:
     core_    → Core analytical tables
     ref_     → Reference / enrichment tables
     results_ → Data quality & outputs

   ============================================================================ */

USE olist360;

-- ============================================================
-- 1) Core Analytical Tables
-- ============================================================

RENAME TABLE
  raw_orders           TO core_orders,
  raw_customers        TO core_customers,
  raw_order_items      TO core_order_items,
  raw_order_payments   TO core_payments,
  raw_order_reviews    TO core_reviews,
  raw_products         TO core_products,
  raw_sellers          TO core_sellers;

-- ============================================================
-- 2) Reference / Enrichment Tables
-- ============================================================

RENAME TABLE
  raw_geolocation           TO ref_geolocation,
  raw_category_translation  TO ref_category_translation;

-- ============================================================
-- 3) Results / Data Quality Tables
-- ============================================================

RENAME TABLE
  dq_runs    TO results_dq_runs,
  dq_results TO results_dq_results;

-- ============================================================
-- 4) Validation – Check final structure
-- ============================================================

SHOW TABLES FROM olist360;