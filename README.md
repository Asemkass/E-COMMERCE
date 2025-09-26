# E-COMMERCE
Olist brazilian E-commerce dataset
 О проекте
Этот проект представляет собой комплексный анализ данных бразильского e-commerce магазина Olist. Включает создание базы данных PostgreSQL, импорт данных, выполнение аналитических запросов и визуализацию результатов.
![photo_5377409100700319155_y](https://github.com/user-attachments/assets/cfa6fcb5-10ac-409b-b5aa-c53d6d6a814e)



![ER Diagram](photo_5377409100700319155_y)

---

## ⚙️ Установка PostgreSQL

1. Скачайте [PostgreSQL](https://www.postgresql.org/download/) с официального сайта.
2. Установите с настройками по умолчанию.
3. Запомните пароль пользователя `postgres`.

---

## 🗂️ Структура данных

База данных содержит **9 таблиц**:

| Таблица                             | Описание                   |
| ----------------------------------- | -------------------------- |
| `olist_customers`                   | информация о клиентах      |
| `olist_geolocation`                 | географические данные      |
| `olist_orders`                      | данные о заказах           |
| `olist_order_items`                 | товары в заказах           |
| `olist_order_payments`              | платежи                    |
| `olist_order_reviews`               | отзывы клиентов            |
| `olist_products`                    | информация о товарах       |
| `olist_sellers`                     | данные продавцов           |
| `product_category_name_translation` | переводы категорий товаров |

---

## 🚀 Как запустить проект

### 1. Клонирование репозитория

```bash
git clone https://github.com/your-username/olist-ecommerce.git
cd olist-ecommerce
```

### 2. Создание базы данных

Войдите в PostgreSQL:

```bash
psql -U postgres
```

Создайте базу:

```sql
CREATE DATABASE olist;
```

### 3. Создание таблиц

Выполните SQL-скрипт:

```bash
psql -U postgres -d olist -f create_tables.sql
```

### 4. Импорт данных

Импортируйте CSV-файлы (пример для `olist_customers`):

```bash
\copy olist_customers(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state) 
FROM 'data/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;
```

Повторите для остальных таблиц (`olist_orders`, `olist_order_items` и т.д.).

### 5. Запуск аналитики в Python

Установите зависимости:

```bash
pip install -r requirements.txt
```

Запустите Jupyter Notebook:

```bash
jupyter notebook
```

Откройте файл `analysis.ipynb` и выполните ячейки.

---

## 📊 Результат

* Поднята база данных **Olist**.
* Составлена **ER-диаграмма** связей между таблицами.
* Реализованы **SQL-запросы** для анализа заказов, оплат, отзывов и географии.
* Построены **визуализации в Python** (графики по продажам, отзывам и доставкам).

---

👉 Хочешь, я тебе сразу подготовлю полный **`create_tables.sql`** + **`requirements.txt`** для Python (pandas, psycopg2, matplotlib), чтобы у тебя было всё готово к пушу на GitHub?
