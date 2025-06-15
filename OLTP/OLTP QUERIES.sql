-- 1. Сколько заказов сделано каждым клиентом?

SELECT customer_email, COUNT(*) AS orders_count
FROM orders
GROUP BY customer_email
ORDER BY orders_count DESC;

-- 2. Общая выручка по каждому товару

SELECT product_name, SUM(quantity * unit_price) AS total_revenue
FROM orders
GROUP BY product_name
ORDER BY total_revenue DESC;

-- 3. Сколько заказов в каждом статусе?

SELECT order_status, COUNT(*) AS count_orders
FROM orders
GROUP BY order_status
ORDER BY count_orders DESC;
