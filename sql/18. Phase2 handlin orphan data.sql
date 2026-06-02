SELECT DISTINCT p.product_category_name
FROM core_products p
LEFT JOIN ref_category_translation t
  ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;
  
  /* ============================================================
   DATA COMPLETION – CATEGORY TRANSLATION
   PURPOSE:
   --------
   - Add missing product categories to the reference table
   - Include both original category name and English translation
   - Prepare data for FK enforcement
   ============================================================ */

INSERT INTO ref_category_translation (
    product_category_name,
    product_category_name_english
)
VALUES
    ('pc_gamer', 'PC gamer'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 
     'Portable kitchen and food preparation appliances');