# 🍎 Apple Global Sales — End-to-End SQL Project

A complete end-to-end SQL portfolio project analysing Apple's global sales data (2022–2024) using MySQL. Covers database design, data loading, cleaning, exploration, 30 business questions, and reusable views & stored procedures.

---

## 📁 Project Structure

```
apple-sql-project/
├── data/
│   └── apple_global_sales_dataset.csv
├── sql/
│   ├── 01_schema.sql
│   ├── 02_load_data.sql
│   ├── 03_data_cleaning.sql
│   ├── 04_exploration.sql
│   ├── 05_business_q1_q5.sql
│   ├── 06_business_q6_q10.sql
│   ├── 07_business_q11_q15.sql
│   ├── 08_business_q16_q20.sql
│   ├── 09_business_q21_q25.sql
│   ├── 10_business_q26_q30.sql
│   └── 11_views_and_procedures.sql
└── README.md
```

---

## 🗃️ Dataset

| Property | Detail |
|---|---|
| Source | [Kaggle — Apple Global Sales Dataset]([https://www.kaggle.com](https://www.kaggle.com/datasets/ashyou09/apple-global-product-sales-dataset)) |
| Rows | 11,500 transactions |
| Columns | 27 |
| Period | January 2022 – December 2024 |
| Geography | Multiple countries across 8 regions |

### Column Overview

| Column | Type | Description |
|---|---|---|
| `sale_id` | CHAR(13) | Unique transaction ID — APPL-XXXXXXXX |
| `sale_date` | DATE | Transaction date |
| `year` | SMALLINT | 2022 / 2023 / 2024 |
| `quarter` | CHAR(2) | Q1 / Q2 / Q3 / Q4 |
| `month` | VARCHAR | Full month name |
| `country` | VARCHAR | Country of sale |
| `region` | VARCHAR | Continent / geo-region |
| `city` | VARCHAR | City of sale |
| `product_name` | VARCHAR | Full product name |
| `category` | VARCHAR | iPhone / iPad / Mac / Apple Watch / AirPods / Accessories |
| `storage` | VARCHAR | Storage variant (NULL for non-storage products) |
| `color` | VARCHAR | Colour option |
| `unit_price_usd` | DECIMAL | Per-unit list price in USD |
| `discount_pct` | DECIMAL | Discount applied: 0, 2, 3, 5, 7, 10, or 15% |
| `units_sold` | TINYINT | Quantity in transaction (1–8) |
| `discounted_price_usd` | DECIMAL | Effective per-unit price after discount |
| `revenue_usd` | DECIMAL | Total transaction revenue in USD |
| `currency` | CHAR(3) | Local currency code |
| `fx_rate_to_usd` | DECIMAL | Exchange rate used for conversion |
| `revenue_local_currency` | DECIMAL | Revenue in local currency |
| `sales_channel` | VARCHAR | Apple Store / Online / Reseller / Carrier / Retailer / B2B |
| `payment_method` | VARCHAR | Credit Card / Debit Card / Apple Pay / EMI / Net Banking / Cash / Gift Card |
| `customer_segment` | VARCHAR | Individual / Business / Education / Government |
| `customer_age_group` | VARCHAR | 18–24 / 25–34 / 35–44 / 45–54 / 55+ |
| `previous_device_os` | VARCHAR | Previous OS (iPhone buyers only; NULL for others) |
| `customer_rating` | DECIMAL | Post-purchase rating 3.0–5.0 (~30% NULL) |
| `return_status` | VARCHAR | Kept / Returned / Exchanged |


## 📊 Business Questions Answered

### Sales Performance (Q1–Q5)
- Q1. Total revenue by year and quarter
- Q2. Which month consistently generates the highest revenue?
- Q3. Which sales channel contributes the most revenue?
- Q4. Month-over-month revenue growth rate
- Q5. What % of transactions use a discount by channel?

### Geography (Q6–Q10)
- Q6. Top 10 cities by revenue
- Q7. Which region has the highest average transaction value?
- Q8. Which countries have the highest return rates?
- Q9. Revenue split across regions per product category
- Q10. Strongest currency markets by exchange-adjusted revenue

### Product Analysis (Q11–Q15)
- Q11. Revenue contribution % per product category
- Q12. Top 5 revenue products per category
- Q13. Best-selling storage variants for iPhone and iPad
- Q14. Most popular color options per category
- Q15. Category revenue share shift year over year

### Customer Insights (Q16–Q20)
- Q16. Which customer segment generates the most revenue?
- Q17. Preferred payment method by age group
- Q18. Which age group buys the most premium products?
- Q19. What % of iPhone buyers switched from Android vs iOS?
- Q20. Which customer segment has the highest return rate?

### Returns & Ratings (Q21–Q25)
- Q21. Return rate by product category
- Q22. Do heavily discounted products get returned more often?
- Q23. Average customer rating per category
- Q24. Correlation between customer rating and return status
- Q25. Which sales channel has the worst return rate?

### Advanced — Window Functions & CTEs (Q26–Q30)
- Q26. Products ranked by revenue within each region — `RANK()`
- Q27. 3-month rolling average of revenue — `ROWS BETWEEN`
- Q28. Top 3 cities per region by units sold — `ROW_NUMBER()`
- Q29. Running total of revenue by sales channel per year
- Q30. Peak revenue quarter per product — CTE + `RANK()`

---

## 🔁 Views & Stored Procedures

### Views
| View | Description |
|---|---|
| `vw_monthly_revenue` | Revenue trends by month and year |
| `vw_category_performance` | Category KPIs — revenue, rating, return rate |
| `vw_regional_summary` | Country-level revenue and return rates |
| `vw_customer_scorecard` | Segment and age group performance |
| `vw_channel_performance` | Channel revenue, discounts, and returns |

### Stored Procedures
| Procedure | Usage | Description |
|---|---|---|
| `sp_revenue_by_year` | `CALL sp_revenue_by_year(2023)` | Revenue by category for any year |
| `sp_top_products` | `CALL sp_top_products('iPhone', 5)` | Top N products for any category |
| `sp_sales_by_daterange` | `CALL sp_sales_by_daterange('2023-01-01', '2023-06-30')` | Sales for any date range |
| `sp_region_country_report` | `CALL sp_region_country_report('Europe')` | Country breakdown for any region |
| `sp_return_report` | `CALL sp_return_report('Apple Store')` | Return analysis for any channel |

---

## 🛠️ SQL Concepts Used

| Concept | Used In |
|---|---|
| `CREATE TABLE` with constraints & indexes | Schema design |
| `LOAD DATA LOCAL INFILE` | Data import |
| `UPDATE`, `TRIM`, `NULLIF` | Data cleaning |
| `GROUP BY`, `HAVING`, `ORDER BY` | Aggregations |
| `CASE WHEN` | Conditional aggregation |
| `WITH` (CTEs) | Multi-step logic |
| `RANK()`, `ROW_NUMBER()`, `LAG()` | Window functions |
| `OVER (PARTITION BY ...)` | Partitioned windows |
| `ROWS BETWEEN ... PRECEDING` | Rolling averages |
| `CREATE VIEW` | Reusable query layers |
| `DELIMITER $$ / CREATE PROCEDURE` | Stored procedures |

---

## 👤 Author

**Your Name**
[LinkedIn]([https://linkedin.com/in/yourprofile](https://www.kaggle.com/datasets/ashyou09/apple-global-product-sales-dataset)) • [GitHub](https://github.com/doniyor-py)

