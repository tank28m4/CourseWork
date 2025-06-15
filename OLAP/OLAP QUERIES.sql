-- 1. Топ-5 клиентов по сумме покупок

SELECT dc.first_name, dc.last_name, dc.email, SUM(fs.total_amount) AS total_spent
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_key = dc.customer_key
GROUP BY dc.first_name, dc.last_name, dc.email
ORDER BY total_spent DESC
LIMIT 5;

-- 2. Выручка по категориям товаров

SELECT dp.category, SUM(fs.total_amount) AS category_revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY category_revenue DESC;

-- 3. Продажи по городам

SELECT dl.city, SUM(fs.total_amount) AS total_sales
FROM fact_sales fs
JOIN dim_location dl ON fs.location_key = dl.location_key
GROUP BY dl.city
ORDER BY total_sales DESC;
