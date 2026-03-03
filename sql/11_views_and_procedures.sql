-- ============================================================
--  Apple Global Sales — Views & Stored Procedures
-- ============================================================

-- ============================================================
--  PART 1: VIEWS
-- ============================================================

CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
  year, month,
  DATE_FORMAT(sale_date, '%Y-%m-01') AS month_start,
  COUNT(*) AS transactions,
  SUM(units_sold) AS units_sold,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(AVG(revenue_usd), 2) AS avg_transaction_usd
FROM apple_sales
GROUP BY year, month, DATE_FORMAT(sale_date, '%Y-%m-01');

CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
  category,
  COUNT(*) AS transactions,
  SUM(units_sold) AS units_sold,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 / SUM(SUM(revenue_usd)) OVER (), 2) AS revenue_pct,
  ROUND(AVG(unit_price_usd), 2) AS avg_unit_price,
  ROUND(AVG(customer_rating), 2) AS avg_rating,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM apple_sales
GROUP BY category;

CREATE OR REPLACE VIEW vw_regional_summary AS
SELECT
  region, country,
  COUNT(*) AS transactions,
  SUM(units_sold) AS units_sold,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(AVG(revenue_usd), 2) AS avg_transaction_usd,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM apple_sales
GROUP BY region, country;

CREATE OR REPLACE VIEW vw_customer_scorecard AS
SELECT
  customer_segment, customer_age_group,
  COUNT(*) AS transactions,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(AVG(revenue_usd), 2) AS avg_transaction_usd,
  ROUND(AVG(unit_price_usd), 2) AS avg_unit_price,
  ROUND(AVG(customer_rating), 2) AS avg_rating,
  ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM apple_sales
GROUP BY customer_segment, customer_age_group;

CREATE OR REPLACE VIEW vw_channel_performance AS
SELECT
  sales_channel,
  COUNT(*) AS transactions,
  ROUND(SUM(revenue_usd), 2) AS revenue_usd,
  ROUND(SUM(revenue_usd) * 100.0 / SUM(SUM(revenue_usd)) OVER (), 2) AS revenue_pct,
  ROUND(AVG(discount_pct), 2) AS avg_discount_pct,
  ROUND(AVG(customer_rating), 2) AS avg_rating,
  ROUND(SUM(CASE WHEN return_status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM apple_sales
GROUP BY sales_channel;

-- ============================================================
--  PART 2: STORED PROCEDURES
-- ============================================================

DROP PROCEDURE IF EXISTS sp_revenue_by_year;
DROP PROCEDURE IF EXISTS sp_top_products;
DROP PROCEDURE IF EXISTS sp_sales_by_daterange;
DROP PROCEDURE IF EXISTS sp_region_country_report;
DROP PROCEDURE IF EXISTS sp_return_report;

-- SP1. CALL sp_revenue_by_year(2023);
DELIMITER $$
CREATE PROCEDURE sp_revenue_by_year(IN p_year INT)
BEGIN
  SELECT category,
    COUNT(*) AS transactions, SUM(units_sold) AS units_sold,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd,
    ROUND(AVG(unit_price_usd), 2) AS avg_unit_price
  FROM apple_sales WHERE year = p_year
  GROUP BY category ORDER BY revenue_usd DESC;
END$$
DELIMITER ;

-- SP2. CALL sp_top_products('iPhone', 5);
DELIMITER $$
CREATE PROCEDURE sp_top_products(
  IN p_category VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN p_limit INT
)
BEGIN
  SELECT product_name, storage,
    COUNT(*) AS transactions, SUM(units_sold) AS units_sold,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd,
    ROUND(AVG(customer_rating), 2) AS avg_rating
  FROM apple_sales WHERE category = p_category
  GROUP BY product_name, storage
  ORDER BY revenue_usd DESC LIMIT p_limit;
END$$
DELIMITER ;

-- SP3. CALL sp_sales_by_daterange('2023-01-01', '2023-06-30');
DELIMITER $$
CREATE PROCEDURE sp_sales_by_daterange(IN p_start DATE, IN p_end DATE)
BEGIN
  SELECT category, sales_channel,
    COUNT(*) AS transactions, SUM(units_sold) AS units_sold,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd,
    ROUND(AVG(discount_pct), 2) AS avg_discount_pct
  FROM apple_sales WHERE sale_date BETWEEN p_start AND p_end
  GROUP BY category, sales_channel ORDER BY revenue_usd DESC;
END$$
DELIMITER ;

-- SP4. CALL sp_region_country_report('Europe');
DELIMITER $$
CREATE PROCEDURE sp_region_country_report(
  IN p_region VARCHAR(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
  SELECT country,
    COUNT(*) AS transactions, SUM(units_sold) AS units_sold,
    ROUND(SUM(revenue_usd), 2) AS revenue_usd,
    ROUND(AVG(revenue_usd), 2) AS avg_transaction_usd,
    ROUND(AVG(customer_rating), 2) AS avg_rating,
    ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_rate_pct
  FROM apple_sales WHERE region = p_region
  GROUP BY country ORDER BY revenue_usd DESC;
END$$
DELIMITER ;

-- SP5. CALL sp_return_report('Apple Store');
DELIMITER $$
CREATE PROCEDURE sp_return_report(
  IN p_channel VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
  SELECT category,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN return_status = 'Returned'  THEN 1 ELSE 0 END) AS returned,
    SUM(CASE WHEN return_status = 'Exchanged' THEN 1 ELSE 0 END) AS exchanged,
    ROUND(SUM(CASE WHEN return_status != 'Kept' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS return_exchange_rate_pct,
    ROUND(AVG(customer_rating), 2) AS avg_rating
  FROM apple_sales WHERE sales_channel = p_channel
  GROUP BY category ORDER BY return_exchange_rate_pct DESC;
END$$
DELIMITER ;

SELECT * FROM vw_monthly_revenue      ORDER BY month_start;
SELECT * FROM vw_category_performance ORDER BY revenue_usd DESC;
SELECT * FROM vw_regional_summary     ORDER BY revenue_usd DESC;
SELECT * FROM vw_customer_scorecard   ORDER BY revenue_usd DESC;
SELECT * FROM vw_channel_performance  ORDER BY revenue_usd DESC;

CALL sp_revenue_by_year(2022);
CALL sp_revenue_by_year(2023);
CALL sp_revenue_by_year(2024);
CALL sp_top_products('iPhone', 5);
CALL sp_top_products('Mac', 3);
CALL sp_top_products('iPad', 5);
CALL sp_sales_by_daterange('2023-01-01', '2023-06-30');
CALL sp_sales_by_daterange('2024-01-01', '2024-12-31');
CALL sp_region_country_report('Europe');
CALL sp_region_country_report('Asia');
CALL sp_region_country_report('North America');
CALL sp_return_report('Apple Store');
CALL sp_return_report('Online (Apple.com)');
CALL sp_return_report('Authorized Reseller');