/* ============================================================
   STEP: Build Surrogate Primary Key for core_reviews
   Schema: olist360

   CONTEXT (your case):
   - review_id is NOT unique (duplicates exist)
   - review_id cannot be used as a Primary Key
   - We need a reliable row-level identifier

   SOLUTION:
   - Add a Surrogate Primary Key (auto-increment)
   - Keep review_id as a business/reference column
   - Use order_id as a Foreign Key later (NOT PK)

   ============================================================ */

-- ------------------------------------------------------------
-- 1) Make sure we are using the correct database
-- ------------------------------------------------------------
USE olist360;

-- ------------------------------------------------------------
-- 2) Add a Surrogate Primary Key column
-- ------------------------------------------------------------
/*
   WHAT THIS DOES:
   - Adds a new column: review_row_id
   - BIGINT: safe for large tables
   - AUTO_INCREMENT: database generates values automatically (1,2,3,...)
   - PRIMARY KEY: guarantees each row is uniquely identifiable

   WHY WE DO THIS:
   - review_id is duplicated → cannot be PK
   - We need a unique identifier per row
*/
ALTER TABLE core_reviews
  ADD COLUMN review_row_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- ------------------------------------------------------------
-- 3) Add supporting indexes (performance + relationships)
-- ------------------------------------------------------------
/*
   These are NOT primary keys.
   They improve query performance and future joins.

   review_id:
   - Still useful for analysis and filtering
   - Indexed for fast lookups

   order_id:
   - Will be used as a Foreign Key to core_orders
   - Indexed to make joins efficient
*/
CREATE INDEX idx_core_reviews_review_id
  ON core_reviews(review_id);

CREATE INDEX idx_core_reviews_order_id
  ON core_reviews(order_id);

-- ------------------------------------------------------------
-- 4) Verification queries (run to visually confirm the result)
-- ------------------------------------------------------------

/*
   A) Check that the PRIMARY KEY exists
   You should see an index named 'PRIMARY'
   on column review_row_id
*/
SHOW INDEX FROM core_reviews;

/*
   B) Preview rows to confirm surrogate key values
   review_row_id should be sequential numbers (1,2,3,...)
*/
SELECT
  review_row_id,
  review_id,
  order_id,
  review_score
FROM core_reviews
LIMIT 10;
