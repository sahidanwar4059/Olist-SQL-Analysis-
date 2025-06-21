-- 1. Customers Table
CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY, 
    customer_zip_code_prefix INT,
    customer_city VARCHAR,
    customer_state VARCHAR
);
--load data into table 
copy customers from 'C:\Program Files\PostgreSQL\17\data\customers.csv' delimiter ',' header csv;

-- 2. Orders Table
CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

--load data into table 
copy orders from 'C:\Program Files\PostgreSQL\17\data\orders.csv' delimiter ',' header csv;

-- 3. Products Table
CREATE TABLE products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_length NUMERIC,
    product_description_length NUMERIC,
    product_photos_qty INT,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);
--load data into table 
copy products from 'C:\Program Files\PostgreSQL\17\data\products.csv' delimiter ',' header csv;



-- 4. Sellers Table
CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR,
    seller_state VARCHAR
);
--load data into table 
copy sellers from 'C:\Program Files\PostgreSQL\17\data\sellers.csv' delimiter ',' header csv;
-- 5. Order_Items Table
CREATE TABLE order_items (
    order_id VARCHAR,
    order_item_id INT,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);
--load data into table 
copy order_items from 'C:\Program Files\PostgreSQL\17\data\order_items.csv' delimiter ',' header csv;



-- 6. Order Reviews Table
CREATE TABLE reviews (
    review_id VARCHAR PRIMARY KEY,
    order_id VARCHAR,
    review_score INT,
    review_comment_title VARCHAR,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
--load data into table 
copy reviews from 'C:\Program Files\PostgreSQL\17\data\reviews.csv' delimiter ',' header csv;
-- 7. Order Payments Table
CREATE TABLE payments (       
    order_id VARCHAR,
    payment_sequential INT,
    payment_type VARCHAR,
    payment_installments INT,
    payment_value NUMERIC,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
--load data into table 
copy payments from 'C:\Program Files\PostgreSQL\17\data\payments.csv' delimiter ',' header csv;

 --Basic Joins
--1. Orders with Customers

SELECT
	*
FROM
	ORDERS O
	JOIN CUSTOMERS C ON O.CUSTOMER_ID = C.CUSTOMER_ID;

--2. Orders with Products
SELECT
	*
FROM
	ORDERS O
	JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID;

--3. Orders with Payments
SELECT
	*
FROM
	ORDERS O
	JOIN PAYMENTS P ON O.ORDER_ID = P.ORDER_ID;

--4. Orders with Reviews
SELECT
	*
FROM
	ORDERS O
	JOIN REVIEWS R ON O.ORDER_ID = R.ORDER_ID;

--5. Orders with Sellers
SELECT
	*
FROM
	ORDERS O
	JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN SELLERS S ON OI.SELLER_ID = S.SELLER_ID;


--Key Metrics & Aggregates

 
--1.Total Sales Value & Order Count
SELECT
	COUNT(O.ORDER_ID) AS TOTAL_ORDERS,
	SUM(P.PAYMENT_VALUE) AS TOTAL_REVENUE
FROM
	ORDERS O
	JOIN PAYMENTS P ON O.ORDER_ID = P.ORDER_ID;

	

--2.Monthly Sales Trend
SELECT
	DATE_TRUNC('month', O.ORDER_PURCHASE_TIMESTAMP) AS ORDER_MONTH,
	SUM(P.PAYMENT_VALUE) AS TOTAL_REVENUE
FROM
	ORDERS O
	JOIN PAYMENTS P ON O.ORDER_ID = P.ORDER_ID
GROUP BY
	ORDER_MONTH
ORDER BY
	TOTAL_REVENUE DESC;

--Top 10 Cities by Orders

SELECT
	C.CUSTOMER_CITY,
	COUNT(O.ORDER_ID) AS TOTAL_ORDER
FROM
	ORDERS O
	JOIN CUSTOMERS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY
	C.CUSTOMER_CITY
ORDER BY
	TOTAL_ORDER DESC LIMIT
	10;

--Repeat Customers Count
SELECT DISTINCT
	CUSTOMER_ID,
	COUNT(ORDER_ID) AS REPEAT_CUSTOMERS
FROM
	ORDERS
GROUP BY
	CUSTOMER_ID
HAVING
	COUNT(ORDER_ID) > 1;

SELECT
	COUNT(*) AS REPEAT_CUSTOMERS
FROM
	(
		SELECT
			CUSTOMER_ID
		FROM
			ORDERS
		GROUP BY
			CUSTOMER_ID
		HAVING
			COUNT(ORDER_ID) > 1
	) AS SUB;

--Top 10 Selling Products
SELECT
	P.PRODUCT_ID,
	COUNT(OI.ORDER_ID) AS TOTAL_SOLD,
	SUM(OI.PRICE) AS REVENUE_GENERATED
FROM
	ORDER_ITEMS OI
	JOIN PRODUCTS P ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY
	P.PRODUCT_ID
ORDER BY
	TOTAL_SOLD DESC
LIMIT
	10;

---Average Freight per Product Category
SELECT
	P.PRODUCT_CATEGORY_NAME,
	AVG(OI.FREIGHT_VALUE) AS AVG_FREIGHT
FROM
	ORDER_ITEMS OI
	JOIN PRODUCTS P ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY
	P.PRODUCT_CATEGORY_NAME
ORDER BY
	AVG_FREIGHT DESC;---Logistics / Delivery Performance
SELECT 
    ROUND(AVG(order_delivered_customer_date - order_purchase_timestamp), 2) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

---Late Deliveries Count
SELECT 
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;


--Payment Mode Distribution

SELECT
	PAYMENT_TYPE,
	COUNT(*) AS TOTAL_TRANSACTIONS,
	ROUND(SUM(PAYMENT_VALUE), 2) AS TOTAL_PAYMENT_VALUE
FROM
	PAYMENTS
GROUP BY
	PAYMENT_TYPE
ORDER BY
	TOTAL_PAYMENT_VALUE DESC;
--EMI / Installment Usage

SELECT
	COUNT(*) AS EMI_ORDERS
FROM
	PAYMENTS
WHERE
	PAYMENT_INSTALLMENTS > 1;
--Customer Reviews & Feedback
--Review Score Distribution

SELECT
	REVIEW_SCORE,
	COUNT(*) AS TOTAL_REVIEWS
FROM
	REVIEWS
GROUP BY
	REVIEW_SCORE
ORDER BY
	REVIEW_SCORE;
--Avg Review Score per Product

SELECT
	P.PRODUCT_ID,
	ROUND(AVG(R.REVIEW_SCORE), 2) AS AVG_RATING
FROM
	ORDER_ITEMS OI
	JOIN PRODUCTS P ON P.PRODUCT_ID = OI.PRODUCT_ID
	JOIN OREVIEWS R ON R.ORDER_ID = OI.ORDER_ID
GROUP BY
	P.PRODUCT_ID
ORDER BY
	AVG_RATING DESC;
--Seller Performance
--Top 5 Sellers by Revenue
SELECT
	S.SELLER_ID,
	SUM(OI.PRICE) AS TOTAL_SALES
FROM
	ORDER_ITEMS OI
	JOIN SELLERS S ON S.SELLER_ID = OI.SELLER_ID
GROUP BY
	S.SELLER_ID
ORDER BY
	TOTAL_SALES DESC
LIMIT
	5;
--Orders per Seller

SELECT
	S.SELLER_ID,
	COUNT(DISTINCT OI.ORDER_ID) AS TOTAL_ORDERS
FROM
	ORDER_ITEMS OI
	JOIN SELLERS S ON S.SELLER_ID = OI.SELLER_ID
GROUP BY
	S.SELLER_ID
ORDER BY
	TOTAL_ORDERS DESC;




















