SELECT 'raw_category_translation' AS table_name, COUNT(*) AS row_count FROM raw_category_translation
UNION ALL SELECT 'raw_customers', COUNT(*) FROM raw_customers
UNION ALL SELECT 'raw_geolocation', COUNT(*) FROM raw_geolocation
UNION ALL SELECT 'raw_order_items', COUNT(*) FROM raw_order_items
UNION ALL SELECT 'raw_order_payments', COUNT(*) FROM raw_order_payments
UNION ALL SELECT 'raw_order_reviews', COUNT(*) FROM raw_order_reviews
UNION ALL SELECT 'raw_orders', COUNT(*) FROM raw_orders
UNION ALL SELECT 'raw_products', COUNT(*) FROM raw_products
UNION ALL SELECT 'raw_sellers', COUNT(*) FROM raw_sellers
ORDER BY table_name;