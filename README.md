# E-COMMERCE
Olist brazilian E-commerce dataset
 О проекте
Этот проект представляет собой комплексный анализ данных бразильского e-commerce магазина Olist. Включает создание базы данных PostgreSQL, импорт данных, выполнение аналитических запросов и визуализацию результатов.
![photo_5377409100700319155_y](https://github.com/user-attachments/assets/cfa6fcb5-10ac-409b-b5aa-c53d6d6a814e)

Установка PostgreSQL
Скачайте PostgreSQL с официального сайта

Установите с настройками по умолчанию

Запомните пароль пользователя postgres 
Описание данных
База данных содержит 9 таблиц:

olist_customers - информация о клиентах

olist_geolocation - географические данные

olist_orders - данные о заказах

olist_order_items - товары в заказах

olist_order_payments - платежи

olist_order_reviews - отзывы клиентов

olist_products - информация о товарах

Примеры Sql запросов
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
Результат
Поднята база данных Olist.
Составлена ER-диаграмма связей между таблицами.
Реализованы SQL-запросы для анализа заказов, оплат, отзывов и географии.
Построены визуализации в Python.

olist_sellers - данные продавцов

product_category_name_translation - переводы категорий товаров
