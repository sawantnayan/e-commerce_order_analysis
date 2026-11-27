# Olist E-Commerce Order & Delivery Analysis

## Project Overview

This project focuses on analyzing an e-commerce business using SQL and MySQL Workbench.

The analysis uses a sample of the Olist e-commerce dataset to understand order performance, customer distribution, product category revenue, payment methods, freight costs, and delivery duration.

The project demonstrates how SQL can be used to extract meaningful business insights from multiple related datasets using primary keys, foreign keys, joins, subqueries, aggregate functions, and advanced SQL queries.

## Business Problem

An e-commerce business needs to understand its sales performance and order fulfilment operations.

The business wants to identify:

- Which customer states generate the highest revenue?
- Which product categories contribute most to sales?
- Which payment methods are most commonly used?
- How long does it take to deliver orders?
- Which orders take longer to deliver?
- Which customers contribute the highest spending?
- How do order volumes and revenue change over time?

This project uses SQL to answer these business questions and support data-driven decision-making.

## Dataset

The project uses five CSV files from the Olist e-commerce dataset.


### Dataset Files

| File | Description |
|---|---|
| `customers.csv` | Customer location information |
| `orders.csv` | Order details and delivery dates |
| `order_items.csv` | Products purchased in each order, prices and freight |
| `payments.csv` | Payment method and installment information |
| `products.csv` | Product category and weight information |



## Tools & Technologies

- MySQL
- MySQL Workbench
- SQL
- GitHub



### 1. Customers

| Column | Description | Key |
|---|---|---|
| `customer_id` | Unique customer identifier | Primary Key |
| `customer_city` | Customer city | |
| `customer_state` | Customer state | |

### 2. Orders

| Column | Description | Key |
|---|---|---|
| `order_id` | Unique order identifier | Primary Key |
| `customer_id` | Customer who placed the order | Foreign Key |
| `order_purchase_date` | Order purchase date | |
| `order_status` | Current order status | |
| `order_delivered_date` | Order delivery date | |

### 3. Order Items

| Column | Description | Key |
|---|---|---|
| `order_id` | Order identifier | Composite Primary Key / Foreign Key |
| `order_item_id` | Item number within an order | Composite Primary Key |
| `product_id` | Product identifier | Foreign Key |
| `price` | Product price | |
| `freight_value` | Freight cost | |

### 4. Payments

| Column | Description | Key |
|---|---|---|
| `order_id` | Order identifier | Primary Key / Foreign Key |
| `payment_type` | Payment method | |
| `payment_installments` | Number of payment installments | |

### 5. Products

| Column | Description | Key |
|---|---|---|
| `product_id` | Unique product identifier | Primary Key |
| `product_category` | Product category | |
| `product_weight_g` | Product weight in grams | |

## Primary and Foreign Key Relationships

The tables are connected using the following relationships:

- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`
- `payments.order_id` → `orders.order_id`

The `order_items` table uses a composite primary key:

`PRIMARY KEY (order_id, order_item_id)`

This allows an order to contain multiple items while maintaining unique item numbers within each order.

## SQL Analysis Performed

### 1. Basic SQL Queries

- SELECT statements
- Filtering records using WHERE
- Sorting records using ORDER BY
- Counting total orders
- Grouping orders by status
- Calculating total revenue
- Calculating average product price
- Filtering grouped results using HAVING

### 2. JOIN Operations

- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- Joining orders with customers
- Joining orders with payments
- Joining order items with products
- Calculating revenue by customer state
- Calculating revenue by product category

### 3. Subqueries

- Products priced above average
- Customers who placed orders
- Customers without orders
- States
