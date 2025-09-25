import pandas as pd
import psycopg2
from psycopg2 import sql
import os
from dotenv import load_dotenv

load_dotenv()

class OlistDatabase:
    def __init__(self):
        self.connection = None
        self.connect()
    
    def connect(self):
        try:
            self.connection = psycopg2.connect(
                host=os.getenv('DB_HOST', 'localhost'),
                database=os.getenv('DB_NAME', 'postgres'),
                user=os.getenv('DB_USER', 'postgres'),
                password=os.getenv('DB_PASSWORD', ''),
                port=os.getenv('DB_PORT', '5432')
            )
            print("Успешное подключение к базе данных")
        except Exception as e:
            print(f"Ошибка подключения: {e}")
    
    def execute_query(self, query, params=None):
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, params)
                
        
                if cursor.description:
                    columns = [desc[0] for desc in cursor.description]
                    results = cursor.fetchall()
                    return pd.DataFrame(results, columns=columns)
                else:
                    self.connection.commit()
                    return None
                    
        except Exception as e:
            print(f" Ошибка выполнения запроса: {e}")
            return None
    
    def close(self):
        if self.connection:
            self.connection.close()
            print(" Соединение с базой данных закрыто")

def main():
    db = OlistDatabase()
    
    queries = {
        "top_categories": """
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
        """,
        
        "top_sellers": """
            SELECT 
                s.seller_id,
                s.seller_city,
                s.seller_state,
                COUNT(DISTINCT oi.order_id) as total_orders,
                ROUND(SUM(oi.price), 2) as total_revenue,
                ROUND(AVG(oi.price), 2) as avg_order_value
            FROM olist_sellers s
            JOIN olist_order_items oi ON s.seller_id = oi.seller_id
            GROUP BY s.seller_id, s.seller_city, s.seller_state
            ORDER BY total_revenue DESC
            LIMIT 10;
        """,
        
        "payment_analysis": """
            SELECT 
                payment_type,
                COUNT(*) as payment_count,
                ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_order_payments), 2) as percentage,
                ROUND(AVG(payment_value), 2) as avg_payment_value,
                ROUND(MAX(payment_value), 2) as max_payment_value
            FROM olist_order_payments
            GROUP BY payment_type
            ORDER BY payment_count DESC;
        """,
        
        "customer_satisfaction": """
            SELECT 
                c.customer_state,
                COUNT(r.review_id) as review_count,
                ROUND(AVG(r.review_score), 2) as avg_review_score,
                COUNT(CASE WHEN r.review_score = 5 THEN 1 END) as five_star_reviews
            FROM olist_customers c
            JOIN olist_orders o ON c.customer_id = o.customer_id
            JOIN olist_order_reviews r ON o.order_id = r.order_id
            GROUP BY c.customer_state
            HAVING COUNT(r.review_id) >= 10
            ORDER BY avg_review_score DESC
            LIMIT 10;
        """,
        
        "monthly_sales": """
            SELECT 
                EXTRACT(YEAR FROM o.order_purchase_timestamp) as year,
                EXTRACT(MONTH FROM o.order_purchase_timestamp) as month,
                COUNT(DISTINCT o.order_id) as order_count,
                ROUND(SUM(oi.price), 2) as monthly_revenue
            FROM olist_orders o
            JOIN olist_order_items oi ON o.order_id = oi.order_id
            WHERE o.order_purchase_timestamp IS NOT NULL
            GROUP BY year, month
            ORDER BY year, month;
        """
    }
    
    for query_name, query in queries.items():
        print(f"\n{'='*60}")
        print(f" РЕЗУЛЬТАТЫ ЗАПРОСА: {query_name.upper()}")
        print(f"{'='*60}")
        
        df = db.execute_query(query)
        
        if df is not None:
            print(f"Количество строк: {len(df)}")
            print("\nПервые 10 строк:")
            print(df.head(10).to_string(index=False))
            
            csv_filename = f"{query_name}_results.csv"
            df.to_csv(csv_filename, index=False, encoding='utf-8')
            print(f"\n Результаты сохранены в файл: {csv_filename}")
            
            numeric_columns = df.select_dtypes(include=['number']).columns
            if not numeric_columns.empty:
                print(f"\n Статистика по числовым данным:")
                print(df[numeric_columns].describe().round(2))
        else:
            print("Запрос не вернул результатов")
        
        print(f"{'='*60}")
    
    print(f"\n{'='*60}")
    print(" СВОДНАЯ ИНФОРМАЦИЯ О БАЗЕ ДАННЫХ")
    print(f"{'='*60}")
    
    summary_queries = {
        "Общее количество заказов": "SELECT COUNT(*) as total_orders FROM olist_orders",
        "Общее количество клиентов": "SELECT COUNT(*) as total_customers FROM olist_customers",
        "Общее количество продавцов": "SELECT COUNT(*) as total_sellers FROM olist_sellers",
        "Общее количество товаров": "SELECT COUNT(*) as total_products FROM olist_products",
        "Общая выручка": "SELECT ROUND(SUM(price), 2) as total_revenue FROM olist_order_items"
    }
    
    for desc, query in summary_queries.items():
        result = db.execute_query(query)
        if result is not None:
            value = result.iloc[0, 0]
            print(f"{desc}: {value}")
    
    db.close()

if __name__ == "__main__":
    main()