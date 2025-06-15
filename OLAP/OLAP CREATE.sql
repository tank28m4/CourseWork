-- Создаём все OLAP-таблицы

DROP TABLE IF EXISTS Fact_Sales;
DROP TABLE IF EXISTS Fact_Inventory;
DROP TABLE IF EXISTS Bridge_Product_Category;
DROP TABLE IF EXISTS Dim_Customer;
DROP TABLE IF EXISTS Dim_Product;
DROP TABLE IF EXISTS Dim_Location;

CREATE TABLE Dim_Customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INT,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(50),
    customer_segment VARCHAR(50),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL DEFAULT '9999-12-31',
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE Dim_Product (
    product_key SERIAL PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    price_range VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_Location (
    location_key SERIAL PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    UNIQUE(country, city)
);

CREATE TABLE Fact_Sales (
    sales_key SERIAL PRIMARY KEY,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    location_key INT NOT NULL,
    quantity_sold INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_key) REFERENCES Dim_Customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES Dim_Product(product_key),
    FOREIGN KEY (location_key) REFERENCES Dim_Location(location_key)
);


CREATE INDEX idx_dim_customer_current ON Dim_Customer(is_current);
CREATE INDEX idx_fact_sales_customer ON Fact_Sales(customer_key);
CREATE INDEX idx_fact_sales_product ON Fact_Sales(product_key);