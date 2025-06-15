DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'subcategories_subcategory_name_key'
    ) THEN
        ALTER TABLE subcategories ADD CONSTRAINT subcategories_subcategory_name_key UNIQUE (subcategory_name);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'products_product_name_key'
    ) THEN
        ALTER TABLE products ADD CONSTRAINT products_product_name_key UNIQUE (product_name);
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'inventory_product_location_key'
    ) THEN
        ALTER TABLE inventory ADD CONSTRAINT inventory_product_location_key UNIQUE (product_id, location);
    END IF;
END$$;

CREATE TEMP TABLE temp_categories (
    category_name VARCHAR(100),
    description TEXT
);
COPY temp_categories (category_name, description)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/categories.csv'
WITH (FORMAT csv, HEADER true);
INSERT INTO categories (category_name, description)
SELECT DISTINCT ON (category_name) category_name, description FROM temp_categories
ON CONFLICT (category_name) DO NOTHING;
DROP TABLE temp_categories;

CREATE TEMP TABLE temp_brands (
    brand_name VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(255)
);
COPY temp_brands (brand_name, country, website)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/brands.csv'
WITH (FORMAT csv, HEADER true);
INSERT INTO brands (brand_name, country, website)
SELECT DISTINCT ON (brand_name) brand_name, country, website FROM temp_brands
ON CONFLICT (brand_name) DO NOTHING;
DROP TABLE temp_brands;

CREATE TEMP TABLE temp_subcategories (
    subcategory_name VARCHAR(100),
    category_name VARCHAR(100),
    description TEXT
);
COPY temp_subcategories (subcategory_name, category_name, description)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/subcategories.csv'
WITH (FORMAT csv, HEADER true);
INSERT INTO subcategories (subcategory_name, category_id, description)
SELECT DISTINCT ON (subcategory_name) 
    t.subcategory_name,
    c.category_id,
    t.description
FROM temp_subcategories t
JOIN categories c ON t.category_name = c.category_name
ON CONFLICT (subcategory_name) DO NOTHING;
DROP TABLE temp_subcategories;

CREATE TEMP TABLE temp_products (
    product_name VARCHAR(255),
    subcategory_name VARCHAR(100),
    brand_name VARCHAR(100),
    sku VARCHAR(50),
    price NUMERIC(10,2),
    description TEXT,
    warranty_months INT
);
COPY temp_products (product_name, subcategory_name, brand_name, sku, price, description, warranty_months)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/products.csv'
WITH (FORMAT csv, HEADER true);
INSERT INTO products (product_name, subcategory_id, brand_id, sku, price, description, warranty_months)
SELECT DISTINCT ON (product_name)
    t.product_name,
    s.subcategory_id,
    b.brand_id,
    t.sku,
    t.price,
    t.description,
    t.warranty_months
FROM temp_products t
JOIN subcategories s ON t.subcategory_name = s.subcategory_name
JOIN brands b ON t.brand_name = b.brand_name
ON CONFLICT (product_name) DO NOTHING;
DROP TABLE temp_products;

CREATE TEMP TABLE temp_customers (
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(50),
    postal_code VARCHAR(20)
);
COPY temp_customers (email, first_name, last_name, phone, address, city, country, postal_code)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/customers.csv'
WITH (FORMAT csv, HEADER true);
INSERT INTO customers (email, first_name, last_name, phone, address, city, country, postal_code)
SELECT DISTINCT ON (email)
    email, first_name, last_name, phone, address, city, country, postal_code
FROM temp_customers
ON CONFLICT (email) DO NOTHING;
DROP TABLE temp_customers;

CREATE TEMP TABLE temp_payment_methods (
    method_name VARCHAR(50),
    description TEXT
);
COPY temp_payment_methods (method_name, description)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/payment_methods.csv'
WITH (FORMAT csv, HEADER true);
INSERT INTO payment_methods (method_name, description)
SELECT method_name, description FROM temp_payment_methods
ON CONFLICT (method_name) DO NOTHING;
DROP TABLE temp_payment_methods;

COPY orders (customer_email, product_name, quantity, unit_price, order_date, shipping_address, order_status, payment_method, total_amount)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/orders.csv'
WITH (FORMAT csv, HEADER true);

CREATE TEMP TABLE temp_inventory (
    product_name VARCHAR(255),
    quantity INT,
    location VARCHAR(100)
);
COPY temp_inventory (product_name, quantity, location)
FROM 'C:/Users/rakshas/Desktop/CourseWork/OLTP/inventory.csv'
WITH (FORMAT csv, HEADER true);
INSERT INTO inventory (product_id, quantity, location)
SELECT DISTINCT ON (t.product_name, t.location)
    p.product_id,
    t.quantity,
    t.location
FROM temp_inventory t
JOIN products p ON t.product_name = p.product_name
ON CONFLICT (product_id, location) DO NOTHING;
DROP TABLE temp_inventory;
