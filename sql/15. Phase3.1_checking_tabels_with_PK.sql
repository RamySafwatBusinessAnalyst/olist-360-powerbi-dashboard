/* ============================================================
   PRIMARY KEY INVENTORY SCRIPT
   PURPOSE:
   --------
   - Show which tables HAVE a Primary Key
   - Show which tables DO NOT have a Primary Key
   - List columns participating in each Primary Key

   SAFE:
   -----
   - Read-only (uses INFORMATION_SCHEMA)
   - No data changes

   DATABASE:
   ---------
   olist360
   ============================================================ */

USE olist360;

SELECT
    t.table_name,
    CASE
        WHEN pk.table_name IS NOT NULL THEN 'YES'
        ELSE 'NO'
    END AS has_primary_key,
    pk.pk_columns
FROM information_schema.tables t
LEFT JOIN (
    SELECT
        table_schema,
        table_name,
        GROUP_CONCAT(column_name ORDER BY ordinal_position) AS pk_columns
    FROM information_schema.key_column_usage
    WHERE constraint_name = 'PRIMARY'
      AND table_schema = 'olist360'
    GROUP BY table_schema, table_name
) pk
    ON t.table_schema = pk.table_schema
   AND t.table_name = pk.table_name
WHERE t.table_schema = 'olist360'
  AND t.table_type = 'BASE TABLE'
ORDER BY has_primary_key DESC, t.table_name;