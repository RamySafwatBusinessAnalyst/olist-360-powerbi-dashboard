CREATE DATABASE IF NOT EXISTS olist360
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE olist360;
USE olist360;

-- 1) Customers
CREATE TABLE IF NOT EXISTS raw_customers (
  customer_id               VARCHAR(50),
  customer_unique_id        VARCHAR(50),
  customer_zip_code_prefix  INT,
  customer_city             VARCHAR(100),
  customer_state            VARCHAR(10)
);

-- 2) Geolocation
CREATE TABLE IF NOT EXISTS raw_geolocation (
  geolocation_zip_code_prefix INT,
  geolocation_lat            DECIMAL(10,7),
  geolocation_lng            DECIMAL(10,7),
  geolocation_city           VARCHAR(100),
  geolocation_state          VARCHAR(10)
);

-- 3) Orders
CREATE TABLE IF NOT EXISTS raw_orders (
  order_id                      VARCHAR(50),
  customer_id                   VARCHAR(50),
  order_status                  VARCHAR(30),
  order_purchase_timestamp      VARCHAR(30),
  order_approved_at             VARCHAR(30),
  order_delivered_carrier_date  VARCHAR(30),
  order_delivered_customer_date VARCHAR(30),
  order_estimated_delivery_date VARCHAR(30)
);

-- 4) Order Items
CREATE TABLE IF NOT EXISTS raw_order_items (
  order_id             VARCHAR(50),
  order_item_id        INT,
  product_id           VARCHAR(50),
  seller_id            VARCHAR(50),
  shipping_limit_date  VARCHAR(30),
  price                DECIMAL(12,2),
  freight_value        DECIMAL(12,2)
);

-- 5) Payments
CREATE TABLE IF NOT EXISTS raw_order_payments (
  order_id              VARCHAR(50),
  payment_sequential    INT,
  payment_type          VARCHAR(30),
  payment_installments  INT,
  payment_value         DECIMAL(12,2)
);

-- 6) Reviews
CREATE TABLE IF NOT EXISTS raw_order_reviews (
  review_id               VARCHAR(50),
  order_id                VARCHAR(50),
  review_score            INT,
  review_comment_title    TEXT,
  review_comment_message  TEXT,
  review_creation_date    VARCHAR(30),
  review_answer_timestamp VARCHAR(30)
);

-- 7) Products
CREATE TABLE IF NOT EXISTS raw_products (
  product_id                 VARCHAR(50),
  product_category_name      VARCHAR(80),
  product_name_lenght        INT,
  product_description_lenght INT,
  product_photos_qty         INT,
  product_weight_g           INT,
  product_length_cm          INT,
  product_height_cm          INT,
  product_width_cm           INT
);

-- 8) Sellers
CREATE TABLE IF NOT EXISTS raw_sellers (
  seller_id              VARCHAR(50),
  seller_zip_code_prefix INT,
  seller_city            VARCHAR(100),
  seller_state           VARCHAR(10)
);

-- 9) Category Translation
CREATE TABLE IF NOT EXISTS raw_category_translation (
  product_category_name         VARCHAR(80),
  product_category_name_english VARCHAR(80)
);

