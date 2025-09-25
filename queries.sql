Топ-10 продавцов по количеству продаж
SELECT 
    s.seller_id, 
    s.seller_city, 
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_order_items oi
JOIN olist_sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_orders DESC
LIMIT 10;

сколько заказов получают отзывы
SELECT 
    CASE 
        WHEN r.review_id IS NOT NULL THEN 'With Review'
        ELSE 'Without Review'
    END as review_status,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM olist_orders WHERE order_status = 'delivered'), 2) as percentage,
    ROUND(AVG(oi.price), 2) as avg_order_value
FROM olist_orders o
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
JOIN olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY review_status;

сколько заказов получают отзывы
SELECT 
    CASE 
        WHEN r.review_id IS NOT NULL THEN 'With Review'
        ELSE 'Without Review'
    END as review_status,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM olist_orders WHERE order_status = 'delivered'), 2) as percentage,
    ROUND(AVG(oi.price), 2) as avg_order_value
FROM olist_orders o
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
JOIN olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY review_status;

В какое время дня совершается больше покупок
SELECT 
    EXTRACT(HOUR FROM o.order_purchase_timestamp) as hour_of_day,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(SUM(oi.price), 2) as total_revenue,
    ROUND(AVG(oi.price), 2) as avg_order_value
FROM olist_orders o
JOIN olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY hour_of_day
ORDER BY hour_of_day;

Среднее количество товаров в заказе и средняя стоимость
SELECT 
    COUNT(oi.order_item_id) as total_items,
    COUNT(DISTINCT oi.order_id) as total_orders,
    ROUND(COUNT(oi.order_item_id) * 1.0 / COUNT(DISTINCT oi.order_id), 2) as avg_items_per_order,
    ROUND(AVG(oi.price), 2) as avg_item_price,
    ROUND(AVG(oi.freight_value), 2) as avg_freight_value
FROM olist_order_items oi;

Анализ эффективности доставки в разных штатах
SELECT 
    c.customer_state,
    COUNT(o.order_id) as order_count,
    ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400), 2) as avg_delivery_days,
    ROUND(MIN(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400), 2) as min_delivery_days,
    ROUND(MAX(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400), 2) as max_delivery_days
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' 
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(o.order_id) >= 50
ORDER BY avg_delivery_days ASC;

Распределение платежей по типам и анализ среднего чека
SELECT 
    payment_type,
    COUNT(*) as payment_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_order_payments), 2) as percentage,
    ROUND(AVG(payment_value), 2) as avg_payment_value,
    ROUND(MAX(payment_value), 2) as max_payment_value,
    ROUND(SUM(payment_value), 2) as total_payment_value
FROM olist_order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

Определяет самых успешных продавцов
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) as total_orders,
    ROUND(SUM(oi.price), 2) as total_revenue,
    ROUND(AVG(oi.price), 2) as avg_order_value,
    ROUND(SUM(oi.freight_value), 2) as total_freight
FROM olist_sellers s
JOIN olist_order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 15;

Анализ сезонности и трендов продаж
SELECT 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) as year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) as month,
    COUNT(DISTINCT o.order_id) as order_count,
    ROUND(SUM(oi.price), 2) as monthly_revenue,
    ROUND(AVG(oi.price), 2) as avg_order_value
FROM olist_orders o
JOIN olist_order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

Считает общее количество проданных товаров по категориям
SELECT 
    pt.product_category_name_english as category_name,
    COUNT(oi.product_id) as total_sold,
    ROUND(AVG(oi.price), 2) as avg_price,
    ROUND(SUM(oi.price), 2) as total_revenue
FROM olist_order_items oi
JOIN olist_products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
GROUP BY pt.product_category_name_english
ORDER BY total_sold DESC
LIMIT 10;