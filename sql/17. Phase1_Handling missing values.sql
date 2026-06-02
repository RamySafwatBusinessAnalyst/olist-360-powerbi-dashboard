/* ============================================================
   DATA CLEANUP SCRIPT – PRODUCT CATEGORY MISSING VALUES
   Schema: olist360

   PURPOSE:
   --------
   - Identify missing product_category_name values (NULL or empty)
   - Standardize missing values into a single placeholder
   - Ensure reference table completeness before FK creation

   NOTE:
   -----
   - This script is a DATA FIX, not a modeling step
   - It will NOT be documented in Phase 3 report
   ============================================================ */

USE olist360;

-- ============================================================
-- STEP 1: IDENTIFY MISSING VALUES
-- ============================================================
/*
   Missing values are defined as:
   - NULL
   - Empty string ('')
*/

SELECT
    COUNT(*) AS missing_category_count
FROM core_products
WHERE product_category_name IS NULL
   OR product_category_name = '';

-- ============================================================
-- STEP 2: STANDARDIZE MISSING VALUES
-- ============================================================
/*
   Replace empty or NULL categories
   with a single controlled value: 'unknown'
*/

UPDATE core_products
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL
   OR product_category_name = '';

-- ============================================================
-- STEP 3: ENSURE REFERENCE TABLE CONTAINS THE VALUE
-- ============================================================
/*
   Insert 'unknown' into ref_category_translation
   if it does not already exist
*/

INSERT INTO ref_category_translation (product_category_name)
SELECT 'unknown'
WHERE NOT EXISTS (
    SELECT 1
    FROM ref_category_translation
    WHERE product_category_name = 'unknown'
);

-- ============================================================
-- END OF DATA CLEANUP SCRIPT
-- ============================================================

/*
   RESULT AFTER EXECUTION:
   -----------------------
   ✅ No NULL or empty product categories remain
   ✅ Reference table is complete
   ✅ Foreign Key creation will succeed
*/
