-- Подключаем FDW и импортируем схему OLTP

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS oltp_server CASCADE;
CREATE SERVER oltp_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'localhost', dbname 'oltp', port '5432');

CREATE USER MAPPING FOR CURRENT_USER
  SERVER oltp_server
  OPTIONS (user 'postgres', password '123');

CREATE SCHEMA IF NOT EXISTS oltp_schema;
IMPORT FOREIGN SCHEMA public
  FROM SERVER oltp_server
  INTO oltp_schema;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'dim_product_product_id_key') THEN
        ALTER TABLE dim_product ADD CONSTRAINT dim_product_product_id_key UNIQUE (product_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'dim_customer_customer_id_key') THEN
        ALTER TABLE dim_customer ADD CONSTRAINT dim_customer_customer_id_key UNIQUE (customer_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'dim_location_country_city_key') THEN
        ALTER TABLE dim_location ADD CONSTRAINT dim_location_country_city_key UNIQUE (country, city);
    END IF;
END$$;

-- Наполнение размерных таблиц

INSERT INTO dim_product (product_id, product_name, category, subcategory, brand, price_range)
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.subcategory_name,
    b.brand_name,
    CASE 
        WHEN p.price < 20 THEN 'Low'
        WHEN p.price < 100 THEN 'Medium'
        ELSE 'High'
    END as price_range
FROM oltp_schema.products p
JOIN oltp_schema.subcategories s ON p.subcategory_id = s.subcategory_id
JOIN oltp_schema.categories c ON s.category_id = c.category_id
JOIN oltp_schema.brands b ON p.brand_id = b.brand_id
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO dim_customer (
    customer_id, email, first_name, last_name, city, country, customer_segment, start_date
)
SELECT
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    c.city,
    c.country,
    'Default',
    CURRENT_DATE
FROM oltp_schema.customers c
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO dim_location (country, city)
SELECT DISTINCT country, city
FROM oltp_schema.customers
ON CONFLICT (country, city) DO NOTHING;

-- Наполнение fact_sales из ПЛОСКОЙ таблицы orders

INSERT INTO fact_sales (
    customer_key, product_key, location_key,
    quantity_sold, unit_price, total_amount, discount_amount
)
SELECT
    dc.customer_key,
    dp.product_key,
    dl.location_key,
    o.quantity,
    o.unit_price,
    o.total_amount,
    0
FROM oltp_schema.orders o
JOIN dim_customer dc ON o.customer_email = dc.email AND dc.is_current
JOIN dim_product dp ON o.product_name = dp.product_name
JOIN oltp_schema.customers c ON o.customer_email = c.email
JOIN dim_location dl ON c.country = dl.country AND c.city = dl.city
WHERE o.quantity IS NOT NULL;