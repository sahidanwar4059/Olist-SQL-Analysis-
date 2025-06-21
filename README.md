# 🗃️ Olist E-Commerce SQL Analysis Project

A real-world SQL project analyzing Brazilian e-commerce data from Olist. The goal is to extract deep business insights using relational queries across customers, orders, payments, products, and reviews.

---

## 📌 Project Objective

Use PostgreSQL to:
- Create normalized database schema
- Load CSV data
- Perform analysis on key business metrics

---

## 📁 Dataset Overview

| Table Name       | Description |
|------------------|-------------|
| `customers`      | Customer details, location info |
| `orders`         | Order events and timestamps |
| `products`       | Category, dimensions |
| `order_items`    | Products per order with price & freight |
| `sellers`        | Seller info |
| `payments`       | Payment methods, values |
| `reviews`        | Rating scores, messages |

---

## 🔍 Key Metrics Covered

- Total Revenue & Orders
- Monthly Sales Trends
- Top Cities by Orders
- Payment Type Usage
- Late Deliveries
- Review Distribution
- Repeat Customers
- Top Sellers by Revenue

---

## 🗂️ Project Structure
Olist_PostgreSQL_Project/
├── olist_schema_and_analysis.sql # Schema + queries
├── Insight_Report.md # Business insights
├── README.md
└── data/
├── customers.csv
├── orders.csv
├── products.csv
├── sellers.csv
├── payments.csv
├── reviews.csv
└── order_items.csv


---

## 🛠️ How to Run

1. Create a new PostgreSQL database.
2. Load the schema and data using:
   ```sql
   \i olist_schema_and_analysis.sql

   
Tools Used
PostgreSQL 13+

pgAdmin or DBeaver

SQL DDL & DML

Acknowledgements
Data Source: Kaggle – Brazilian E-Commerce Public Dataset by Olist

📬 Contact
Name: Your Name

Email: your.email@example.com

LinkedIn: linkedin.com/in/yourprofile
