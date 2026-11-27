CREATE DATABASE olist_analysis;
use olist_analysis;

CREATE TABLE customers(
			customer_id VARCHAR(255) PRIMARY KEY,
            customer_city VARCHAR(200),
            customer_state VARCHAR(100)
            
);

CREATE TABLE products(
			product_id VARCHAR(200) PRIMARY KEY,
            product_category VARCHAR(100),
            product_weight INT
);


CREATE TABLE orders(
			order_id VARCHAR(150) PRIMARY KEY,
            customer_id VARCHAR(200),
            order_purchase_date DATE,
            order_status VARCHAR(100),
            order_delivered_date DATE
);

ALTER TABLE orders
ADD CONSTRAINT fk_order_customers FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


CREATE TABLE order_items (
    order_id VARCHAR(20),
    order_item_id INT,
    product_id VARCHAR(20),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),

    PRIMARY KEY (order_id, order_item_id)
);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_items_products FOREIGN KEY (product_id)
REFERENCES products(product_id);



CREATE TABLE payments (
    order_id VARCHAR(20) PRIMARY KEY,
    payment_type VARCHAR(50),
    payment_installments INT    
);

ALTER TABLE payments
ADD CONSTRAINT fk_order_payments FOREIGN KEY (order_id)
REFERENCES orders(order_id);


-- 1. View all the data 

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM order_items;
SELECT * FROM payments;

-- 2. Find delivered orders

SELECT * FROM orders
WHERE order_status = 'delivered';

-- 3. Find orders that were not delivered

SELECT * FROM orders
WHERE order_status <> 'delivered';

-- 4. Sort orders by purchase date

SELECT * FROM orders
ORDER BY order_purchase_date DESC;

-- 5. Total number of orders

SELECT COUNT(*) as total_orders
FROM orders;

-- 6. Count orders by status

SELECT order_status, COUNT(*) as total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 7. Calculate total product revenue

SELECT SUM(price) AS total_revenue
FROM order_items;

-- 8. Average product price

SELECT ROUND(AVG(price),2) AS average_product_price
FROM order_items;

-- 9. Find states with more than 50 customers

SELECT customer_state, COUNT(*) as total_customers
FROM customers
GROUP BY customer_state
HAVING COUNT(*) > 50
ORDER BY total_customers DESC;

-- 10. Orders with customer city and state

SELECT
    o.order_id,
    o.order_purchase_date,
    o.order_status,
    c.customer_city,
    c.customer_state
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id; 
    
    
-- 11. Customers and their orders

SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    o.order_id,
    o.order_status
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

-- 12. Orders with payment information

SELECT
    o.order_id,
    o.order_status,
    p.payment_type,
    p.payment_installments
FROM orders o
INNER JOIN payments p
    ON o.order_id = p.order_id
ORDER BY payment_installments;

-- 13. Revenue by customer state

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- 14. Order details with product information

SELECT
    oi.order_id,
    oi.product_id,
    p.product_category,
    p.product_weight,
    oi.price,
    oi.freight_value
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id;
    
    
-- 15. Revenue by product category

SELECT
    p.product_category,
    ROUND(SUM(oi.price), 2) AS category_revenue
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY category_revenue DESC;

-- 16. Total freight by state

SELECT
    c.customer_state,
    ROUND(SUM(oi.freight_value), 2) AS total_freight
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_freight DESC;


-- 17. Payment method usage

SELECT
    payment_type,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payments),
        2
    ) AS percentage
FROM payments
GROUP BY payment_type
ORDER BY total_orders DESC;

-- 18. Products priced above the average price

SELECT
    product_id,
    price
FROM order_items
WHERE price > (
    SELECT AVG(price)
    FROM order_items
)
ORDER BY price DESC;


-- 19. Customers who placed an order

SELECT
    customer_id,
    customer_city,
    customer_state
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);

-- 20. Customers who have not placed an order

SELECT
    customer_id,
    customer_city,
    customer_state
FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM orders
    WHERE customer_id IS NOT NULL
);

-- 21. States with revenue above average state revenue

SELECT
    state_revenue.customer_state,
    state_revenue.total_revenue
FROM (
    SELECT
        c.customer_state,
        SUM(oi.price) AS total_revenue
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_state
) AS state_revenue
WHERE state_revenue.total_revenue > (
    SELECT AVG(total_revenue)
    FROM (
        SELECT
            c.customer_state,
            SUM(oi.price) AS total_revenue
        FROM orders o
        JOIN customers c
            ON o.customer_id = c.customer_id
        JOIN order_items oi
            ON o.order_id = oi.order_id
        GROUP BY c.customer_state
    ) AS avg_state_revenue
)
ORDER BY total_revenue DESC;

-- 22. Orders with delivery duration greater than 20 days

SELECT
    order_id,
    order_purchase_date,
    order_delivered_date,
    DATEDIFF(
        order_delivered_date,
        order_purchase_date
    ) AS delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_date IS NOT NULL
  AND DATEDIFF(
      order_delivered_date,
      order_purchase_date
  ) > 20
ORDER BY delivery_days DESC;

-- 23. Products that weigh more than the average product weight

SELECT
    product_id,
    product_category,
    product_weight
FROM products
WHERE product_weight > (
    SELECT AVG(product_weight)
    FROM products
)
ORDER BY product_weight DESC;

-- 24. Count orders in each delivery category

SELECT
    delivery_category,
    COUNT(*) AS total_orders
FROM (
    SELECT
        CASE
            WHEN order_delivered_date IS NULL
                THEN 'Not Delivered'
            WHEN DATEDIFF(
                order_delivered_date,
                order_purchase_date
            ) <= 7
                THEN 'Fast Delivery'
            WHEN DATEDIFF(
                order_delivered_date,
                order_purchase_date
            ) <= 20
                THEN 'Normal Delivery'
            ELSE 'Slow Delivery'
        END AS delivery_category
    FROM orders
) AS delivery_summary
GROUP BY delivery_category
ORDER BY total_orders DESC;

-- 25. Average delivery time

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_date,
                order_purchase_date
            )
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_date IS NOT NULL;
  
-- 26. Revenue and freight by product category

SELECT
    p.product_category,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS revenue_including_freight
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY product_revenue DESC;

-- 27. Top 10 customers by product spending

SELECT
    o.customer_id,
    c.customer_city,
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS total_spending
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.customer_id,
    c.customer_city,
    c.customer_state
ORDER BY total_spending DESC
LIMIT 10;

-- 28. Monthly order volume

SELECT
    DATE_FORMAT(
        order_purchase_date,
        '%Y-%m'
    ) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 29. Monthly revenue

SELECT
    DATE_FORMAT(
        o.order_purchase_date,
        '%Y-%m'
    ) AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;

-- 30. Revenue by payment type

SELECT
    p.payment_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_product_revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY p.payment_type
ORDER BY total_product_revenue DESC;
