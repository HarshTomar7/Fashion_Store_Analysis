-- ============================================
-- FASHION E-COMMERCE SALES ANALYSIS
-- Author : Harsh Singh Tomar
-- Tool   : PostgreSQL
-- Dataset: Fashion Store Transactions (50,000 records)
-- ============================================
--
-- THE STORY:
-- A fashion and lifestyle online store launched in Jan 2023.
-- It started strong, hit a summer slump in mid-2023,
-- recovered in Q4 2023 and peaked in Jan 2024 —
-- then fell every single month after that.
--
-- The business wants to know:
-- Why did the peak not hold? Where is revenue leaking?
-- Which customers and categories are actually worth investing in?
--
-- I had 50,000 transactions from ~4,000 customers
-- across 10 Southeast Asian and international markets.
-- ============================================


CREATE TABLE fashion_store (
    transaction_id   VARCHAR PRIMARY KEY,
    user_name        VARCHAR,
    age_group        VARCHAR,      
    country          VARCHAR,
    product_category VARCHAR,      
    purchase_amount  NUMERIC,
    payment_method   VARCHAR,       
    transaction_date DATE,
    year             INT,
    month            VARCHAR
);


-- ============================================
-- STEP 1 — What are the headline numbers?
-- ============================================

-- I started with the overall business picture before looking at problems.

SELECT
    SUM(purchase_amount)                                        AS total_revenue,
    COUNT(*)                                                    AS total_orders,
    COUNT(DISTINCT LOWER(TRIM(user_name)))                      AS total_customers,
    ROUND(AVG(purchase_amount), 2)                             AS avg_order_value,
    ROUND(SUM(purchase_amount) /
          COUNT(DISTINCT LOWER(TRIM(user_name))), 2)           AS revenue_per_customer
FROM fashion_store;

-- $4.09M revenue · 50K orders · ~4,000 customers · $82 avg order
-- Revenue per customer is $1,020 — higher than it looks because
-- most customers are repeat buyers (87.7% repeat rate).
-- So where is the revenue decline coming from?


-- ============================================
-- STEP 2 — What does the revenue trend look like?
-- ============================================

-- Used LAG() to see month-over-month change.
-- This is where the real story shows up.

WITH monthly AS (
    SELECT
        year,
        month,
        DATE_TRUNC('month', transaction_date)                  AS month_date,
        SUM(purchase_amount)                                   AS revenue
    FROM fashion_store
    GROUP BY year, month, DATE_TRUNC('month', transaction_date)
)
SELECT
    year,
    month,
    ROUND(revenue, 0)                                          AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month_date), 0)          AS prev_month,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month_date))
        / LAG(revenue) OVER (ORDER BY month_date) * 100, 1
    )                                                          AS growth_pct
FROM monthly
ORDER BY month_date;

-- Clear pattern:
-- Jan–Mar 2023: Strong start ($208K → $270K)
-- Jun–Aug 2023: Summer slump — dropped to $78K (off-season fashion buying)
-- Oct–Dec 2023: Strong recovery ($232K → $288K)
-- Jan 2024: All-time peak at $329K
-- Feb–Dec 2024: Fell every single month, ending at just $27K
-- The peak didn't hold. New customer acquisition dried up after Jan 2024.


-- ============================================
-- STEP 3 — Are customers actually coming back?
-- ============================================

-- High repeat rate sounds good. But I wanted to check if
-- the repeat buyers are actually recent or old.

WITH customer_stats AS (
    SELECT
        LOWER(TRIM(user_name))          AS customer_id,
        COUNT(*)                        AS total_orders,
        MIN(transaction_date)           AS first_purchase,
        MAX(transaction_date)           AS last_purchase,
        SUM(purchase_amount)            AS total_spent
    FROM fashion_store
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                         AS total_customers,
    COUNT(CASE WHEN total_orders = 1 THEN 1 END)                    AS one_time_buyers,
    COUNT(CASE WHEN total_orders > 1 THEN 1 END)                    AS repeat_buyers,
    ROUND(COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0
          / COUNT(*), 1)                                            AS repeat_rate_pct,
    ROUND(AVG(total_spent), 2)                                      AS avg_customer_value
FROM customer_stats;

-- 87.7% repeat rate — much better than a typical ecommerce store.
-- Only 12.3% of customers bought once and left.
-- This means the 2024 decline is NOT a retention problem.
-- It's an acquisition problem — the store stopped reaching new customers.


-- ============================================
-- STEP 4 — Which categories drive the most revenue?
-- ============================================

-- Fashion stores live and die by category mix.
-- I wanted to see if the store is too dependent on one category.

WITH total AS (SELECT SUM(purchase_amount) AS grand_total FROM fashion_store)
SELECT
    product_category,
    COUNT(*)                                                          AS orders,
    ROUND(SUM(purchase_amount), 0)                                   AS revenue,
    ROUND(AVG(purchase_amount), 2)                                   AS avg_order_value,
    ROUND(SUM(purchase_amount) / (SELECT grand_total FROM total) * 100, 1) AS revenue_share_pct
FROM fashion_store
GROUP BY product_category
ORDER BY revenue DESC;

-- Fashion = 31.4% of revenue ($1.29M)
-- Footwear = 24.3% ($994K) — high AOV at $110
-- Skincare = 15.7% ($643K)
-- Top 3 categories = 71.4% of revenue
-- Bags have the highest AOV ($140) but only 5% revenue share — underinvested


-- ============================================
-- STEP 5 — Who are the highest value customers?
-- ============================================

SELECT
    LOWER(TRIM(user_name))          AS customer,
    COUNT(*)                        AS total_orders,
    ROUND(SUM(purchase_amount), 0)  AS total_spent,
    ROUND(AVG(purchase_amount), 0)  AS avg_order_value,
    MIN(transaction_date)           AS first_purchase,
    MAX(transaction_date)           AS last_purchase
FROM fashion_store
GROUP BY customer
ORDER BY total_spent DESC
LIMIT 15;

-- Top customer: David Martinez — 64 orders, $5,488 spent
-- Top customers order very frequently (40–65 orders each)
-- These are loyal fashion fans, not just one-time deal hunters


-- ============================================
-- STEP 6 — Customer segmentation
-- ============================================

-- Unlike the typical RFM, I used recency + spend to segment
-- since this store has unusually high repeat rates.

WITH customer_stats AS (
    SELECT
        LOWER(TRIM(user_name))          AS customer_id,
        MAX(transaction_date)           AS last_purchase,
        COUNT(*)                        AS frequency,
        SUM(purchase_amount)            AS monetary
    FROM fashion_store
    GROUP BY customer_id
)
SELECT
    customer_id,
    frequency,
    ROUND(monetary, 0)  AS total_spent,
    CASE
        WHEN monetary > 3000 AND frequency > 30 THEN 'VIP'
        WHEN monetary > 1500 OR frequency > 15  THEN 'Loyal'
        WHEN last_purchase < CURRENT_DATE - INTERVAL '180 days'
                                                THEN 'Fading'
        WHEN frequency = 1                      THEN 'One-time'
        ELSE                                         'Regular'
    END AS segment
FROM customer_stats
ORDER BY monetary DESC;


-- ============================================
-- STEP 7 — Which markets are strongest?
-- ============================================

-- This is a Southeast Asia focused store.
-- I wanted to find which countries are worth doubling down on.

SELECT
    country,
    COUNT(DISTINCT LOWER(TRIM(user_name)))  AS customers,
    ROUND(SUM(purchase_amount), 0)          AS revenue,
    ROUND(AVG(purchase_amount), 2)          AS avg_order_value,
    CASE
        WHEN SUM(purchase_amount) > 500000
         AND AVG(purchase_amount) > 85      THEN 'Priority market'
        WHEN SUM(purchase_amount) > 400000  THEN 'High volume'
        WHEN AVG(purchase_amount) > 90      THEN 'High value'
        ELSE                                     'Growth opportunity'
    END AS market_type
FROM fashion_store
GROUP BY country
ORDER BY revenue DESC;

-- Indonesia = #1 by revenue ($815K)
-- Singapore has the highest AOV — quality buyers spending more per order
-- UAE and Japan are small but high AOV — worth targeting for premium products


-- ============================================
-- STEP 8 — How does age group affect buying behaviour?
-- ============================================

SELECT
    age_group,
    COUNT(*)                        AS orders,
    ROUND(AVG(purchase_amount), 2)  AS avg_order_value,
    ROUND(SUM(purchase_amount), 0)  AS total_revenue,
    ROUND(SUM(purchase_amount) * 100.0 /
          SUM(SUM(purchase_amount)) OVER (), 1) AS revenue_share_pct
FROM fashion_store
GROUP BY age_group
ORDER BY total_revenue DESC;

-- 25-34 age group = 37.9% of revenue ($1.55M)
-- 18-24 = surprisingly strong at 22.2% — young fashion buyers are active
-- 55+ is small but their AOV is slightly higher — less frequent but deliberate buyers


-- ============================================
-- STEP 9 — Which payment methods do customers prefer?
-- ============================================

-- Digital wallets dominating tells us about the market's digital maturity.

SELECT
    payment_method,
    COUNT(*)                        AS transactions,
    ROUND(AVG(purchase_amount), 2)  AS avg_order_value,
    ROUND(SUM(purchase_amount), 0)  AS total_revenue,
    ROUND(SUM(purchase_amount) * 100.0 /
          SUM(SUM(purchase_amount)) OVER (), 1) AS revenue_share_pct
FROM fashion_store
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Digital Wallet = 31.9% of revenue — dominant in Southeast Asia markets
-- Credit Card = 28.1%
-- Buy Now Pay Later = 8.1% — growing fast, especially for higher-ticket Bags/Footwear
-- BNPL users likely have higher AOV — worth tracking separately


-- ============================================
-- STEP 10 — Seasonal pattern: when does the store sell best?
-- ============================================

-- Fashion has strong seasonal patterns. I checked which months
-- consistently perform well across both years.

SELECT
    month,
    ROUND(AVG(CASE WHEN year = 2023 THEN monthly_rev END), 0)  AS avg_2023,
    ROUND(AVG(CASE WHEN year = 2024 THEN monthly_rev END), 0)  AS avg_2024
FROM (
    SELECT
        year,
        month,
        SUM(purchase_amount) AS monthly_rev
    FROM fashion_store
    GROUP BY year, month
) sub
GROUP BY month
ORDER BY avg_2023 DESC NULLS LAST;

-- Jan–Mar and Oct–Dec are consistently the strongest months
-- Jun–Aug is consistently the weakest (summer slump for fashion)
-- The store should plan campaigns and stock around this pattern


-- ============================================
-- END
-- ============================================
