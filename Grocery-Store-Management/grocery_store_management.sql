-- *********** SQL PROJECT *************

-- =========================================================
-- Grocery Store Management Database
-- =========================================================
 

-- Create New Database

CREATE DATABASE Grocery_Store_Management_DB;

-- USE Database

USE Grocery_Store_Management_DB;

-- =========================================================
-- CREATE TABLES
-- =========================================================
-- 1. Supplier Table

CREATE TABLE IF NOT EXISTS supplier (
    sup_id TINYINT PRIMARY KEY,
    sup_name VARCHAR(255),
    address TEXT
);

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    cat_id TINYINT PRIMARY KEY,
    cat_name VARCHAR(255)
);

-- 3. Employees Table
CREATE TABLE IF NOT EXISTS employees (
    emp_id TINYINT PRIMARY KEY,
    emp_name VARCHAR(255),
    hire_date VARCHAR(255)
);

-- 4. Customers Table
CREATE TABLE IF NOT EXISTS customers (
    cust_id SMALLINT PRIMARY KEY,
    cust_name VARCHAR(255),
    address TEXT
);

-- 5. Products Table
CREATE TABLE IF NOT EXISTS products (
    prod_id TINYINT PRIMARY KEY,
    prod_name VARCHAR(255),
    sup_id TINYINT,
    cat_id TINYINT,
    price DECIMAL(10,2),
    FOREIGN KEY (sup_id) REFERENCES supplier(sup_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. Orders Table
CREATE TABLE IF NOT EXISTS orders (
    ord_id SMALLINT PRIMARY KEY,
    cust_id SMALLINT,
    emp_id TINYINT,
    order_date VARCHAR(255),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 7. Order_Details Table
CREATE TABLE IF NOT EXISTS order_details (
    ord_detID SMALLINT AUTO_INCREMENT PRIMARY KEY,
    ord_id SMALLINT,
    prod_id TINYINT,
    quantity TINYINT,
    each_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    FOREIGN KEY (ord_id) REFERENCES orders(ord_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (prod_id) REFERENCES products(prod_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =========================================================
-- Load CSV data into grocery_store_management_db
-- Run once first:  SET GLOBAL local_infile = 1;
-- Then replace <PATH_TO_REPO> in every path below with the folder where you cloned this repo
-- (use forward slashes, e.g. C:/Users/you/sql-projects).
-- =========================================================

SET GLOBAL local_infile = 1;

USE grocery_store_management_db;

-- 1. Suppliers.csv: SupplierID, SupplierName, Address
LOAD DATA LOCAL INFILE '<PATH_TO_REPO>/01-grocery-store-management/dataset/Suppliers.csv'
INTO TABLE supplier
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(sup_id, sup_name, address);

-- 2. Categories.csv: CategoryID, CategoryName
LOAD DATA LOCAL INFILE '<PATH_TO_REPO>/01-grocery-store-management/dataset/Categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(cat_id, cat_name);

-- 3. Store_Employees.csv: EmployeeID, Name, HireDate (M/D/YYYY -> stored as YYYY-MM-DD)
LOAD DATA LOCAL INFILE '<PATH_TO_REPO>/01-grocery-store-management/dataset/Store_Employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(emp_id, emp_name, @hdate)
SET hire_date = DATE_FORMAT(STR_TO_DATE(@hdate, '%m/%d/%Y'), '%Y-%m-%d');

-- 4. Customers.csv: CustomerID, Name, Address
LOAD DATA LOCAL INFILE '<PATH_TO_REPO>/01-grocery-store-management/dataset/Customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(cust_id, cust_name, address);

-- 5. Products.csv: ProductID, Name, SupplierID, CategoryID, Price (depends on supplier, categories)
LOAD DATA LOCAL INFILE '<PATH_TO_REPO>/01-grocery-store-management/dataset/Products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(prod_id, prod_name, sup_id, cat_id, price);

-- 6. Orders.csv: OrderID, CustomerID, EmployeeID, OrderDate (depends on customers, employees)
LOAD DATA LOCAL INFILE '<PATH_TO_REPO>/01-grocery-store-management/dataset/Orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(ord_id, cust_id, emp_id, @odate)
SET order_date = DATE_FORMAT(STR_TO_DATE(@odate, '%m/%d/%Y'), '%Y-%m-%d');

-- 7. OrderDetails.csv: OrderDetailID, OrderID, ProductID, Quantity, PriceEach, TotalPrice
--    (depends on orders, products — note: plain \n line endings, unlike the other 6 files)
LOAD DATA LOCAL INFILE '<PATH_TO_REPO>/01-grocery-store-management/dataset/OrderDetails.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ord_detID, ord_id, prod_id, quantity, each_price, total_price);

-- =========================================================
-- Verify row counts after loading
-- =========================================================
SELECT 'supplier' AS Tables_Name, COUNT(*) AS Rows_loaded FROM supplier
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_details', COUNT(*) FROM order_details;


-- =========================================================
-- ******** ANALYSIS QUESTIONS ********
-- =========================================================

-- =========================================================
-- 1. CUSTOMER INSIGHTS
-- =========================================================

-- How many unique customers have placed orders?
SELECT COUNT(DISTINCT cust_id) AS unique_customers
FROM orders;


-- Which customers have placed the highest number of orders?
SELECT c.cust_name, COUNT(o.ord_id) AS num_orders
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id
ORDER BY num_orders DESC;


-- Total and average purchase value per customer
SELECT c.cust_name,
       ROUND(SUM(od.total_price), 2) AS total_purchase,
       ROUND(AVG(od.total_price), 2) AS avg_purchase
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY c.cust_id
ORDER BY total_purchase DESC;

-- Top 5 customers by total purchase amount
SELECT c.cust_name,
       ROUND(SUM(od.total_price), 2) AS total_purchase
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY c.cust_id
ORDER BY total_purchase DESC
LIMIT 5;


-- =========================================================
-- 2. PRODUCT PERFORMANCE
-- =========================================================

-- How many products exist in each category?
SELECT cat.cat_name, COUNT(p.prod_id) AS num_products
FROM categories cat
JOIN products p ON cat.cat_id = p.cat_id
GROUP BY cat.cat_id
ORDER BY num_products DESC;

-- Average price of products by category
SELECT cat.cat_name, ROUND(AVG(p.price), 2) AS avg_price
FROM categories cat
JOIN products p ON cat.cat_id = p.cat_id
GROUP BY cat.cat_id
ORDER BY avg_price DESC;

-- Products with the highest total sales volume (by quantity)
SELECT p.prod_name, SUM(od.quantity) AS total_units_sold
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id
ORDER BY total_units_sold DESC
LIMIT 10;

-- Total revenue generated by each product
SELECT p.prod_name, ROUND(SUM(od.total_price), 2) AS total_revenue
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id
ORDER BY total_revenue DESC;

-- Product sales by category and supplier
SELECT cat.cat_name, s.sup_name,
       SUM(od.quantity) AS units_sold,
       ROUND(SUM(od.total_price), 2) AS revenue
FROM products p
JOIN categories cat ON p.cat_id = cat.cat_id
JOIN supplier s ON p.sup_id = s.sup_id
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY cat.cat_id, s.sup_id
ORDER BY revenue DESC;


-- =========================================================
-- 3. SALES AND ORDER TRENDS
-- =========================================================

-- Total number of orders placed
SELECT COUNT(*) AS total_orders FROM orders;

-- Average value per order
SELECT ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT o.ord_id, SUM(od.total_price) AS order_total
    FROM orders o
    JOIN order_details od ON o.ord_id = od.ord_id
    GROUP BY o.ord_id
) t;

-- Dates with the most orders placed
SELECT order_date, COUNT(*) AS num_orders
FROM orders
GROUP BY order_date
ORDER BY num_orders DESC
LIMIT 10;

-- Monthly trends in order volume and revenue
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       COUNT(DISTINCT o.ord_id) AS num_orders,
       ROUND(SUM(od.total_price), 2) AS revenue
FROM orders o
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY month
ORDER BY month;

-- Order patterns across weekdays vs weekends
SELECT CASE
         WHEN DAYOFWEEK(o.order_date) IN (1, 7) THEN 'Weekend'
         ELSE 'Weekday'
       END AS day_type,
       COUNT(DISTINCT o.ord_id) AS num_orders,
       ROUND(SUM(od.total_price), 2) AS revenue
FROM orders o
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY day_type;


-- =========================================================
-- 4. SUPPLIER CONTRIBUTION
-- =========================================================

-- How many suppliers are there?
SELECT COUNT(*) AS total_suppliers FROM supplier;

-- Which supplier provides the most products?
SELECT s.sup_name, COUNT(p.prod_id) AS num_products
FROM supplier s
JOIN products p ON s.sup_id = p.sup_id
GROUP BY s.sup_id
ORDER BY num_products DESC;

-- Average price of products from each supplier
SELECT s.sup_name, ROUND(AVG(p.price), 2) AS avg_price
FROM supplier s
JOIN products p ON s.sup_id = p.sup_id
GROUP BY s.sup_id
ORDER BY avg_price DESC;

-- Suppliers contributing the most to total revenue
SELECT s.sup_name, ROUND(SUM(od.total_price), 2) AS total_revenue
FROM supplier s
JOIN products p ON s.sup_id = p.sup_id
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY s.sup_id
ORDER BY total_revenue DESC;


-- =========================================================
-- 5. EMPLOYEE PERFORMANCE
-- =========================================================

-- How many employees have processed orders?
SELECT COUNT(DISTINCT emp_id) AS employees_with_orders FROM orders;

-- Employees who handled the most orders
SELECT e.emp_name, COUNT(o.ord_id) AS num_orders
FROM employees e
JOIN orders o ON e.emp_id = o.emp_id
GROUP BY e.emp_id
ORDER BY num_orders DESC;

-- Total sales value processed by each employee
SELECT e.emp_name, ROUND(SUM(od.total_price), 2) AS total_sales
FROM employees e
JOIN orders o ON e.emp_id = o.emp_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY e.emp_id
ORDER BY total_sales DESC;

-- Average order value handled per employee
SELECT e.emp_name, ROUND(AVG(od.total_price), 2) AS avg_order_value
FROM employees e
JOIN orders o ON e.emp_id = o.emp_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY e.emp_id
ORDER BY avg_order_value DESC;


-- =========================================================
-- 6. ORDER DETAILS DEEP DIVE
-- =========================================================

-- Relationship between quantity ordered and total price
SELECT quantity, ROUND(AVG(total_price), 2) AS avg_total_price
FROM order_details
GROUP BY quantity
ORDER BY quantity;

-- Average quantity ordered per product
SELECT p.prod_name, ROUND(AVG(od.quantity), 2) AS avg_quantity
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id
ORDER BY avg_quantity DESC;

-- How unit price (each_price) varies across products
SELECT p.prod_name,
       MIN(od.each_price) 
AS min_price_charged,
       MAX(od.each_price) AS max_price_charged,
       ROUND(AVG(od.each_price), 2) AS avg_price_charged
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id
ORDER BY p.prod_name;