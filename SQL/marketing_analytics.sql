-- =========================================
-- MARKETING ANALYTICS INTELLIGENCE PROJECT
-- =========================================
-- Tool: PostgreSQL
-- Dataset: Marketing Campaign Dataset
-- Author: Harsh Singh Tomar
--
-- Objective:
-- Analyze campaign effectiveness, ROI, customer behavior,
-- and identify growth opportunities.
-- =========================================

create database marketing


-- =========================
-- TABLE CREATION
-- =========================

CREATE TABLE marketing (
    campaign_id INT PRIMARY KEY,
    company VARCHAR,
    campaign_type VARCHAR,
    target_audience VARCHAR,
    days_long INT,
    channel_used VARCHAR,
    conversion_rate FLOAT,
    acquisition_cost NUMERIC,
    roi FLOAT,
    location VARCHAR,
    language VARCHAR,
    clicks INT,
    impressions INT,
    engagement_score NUMERIC,
    market_segment VARCHAR,
    campaign_date DATE,
    gender VARCHAR,
    age_group VARCHAR
);
drop table marketing



-- =========================
-- SECTION A: CORE KPIs
-- =========================

SELECT 
    COUNT(*) AS total_campaigns,
    SUM(clicks) AS total_clicks,
    SUM(impressions) AS total_impressions,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2) AS overall_ctr,
    AVG(conversion_rate) AS avg_conversion_rate,
    AVG(roi) AS avg_roi,
    SUM(acquisition_cost) AS total_spend
FROM marketing;


-- =========================
-- SECTION B: COMPANY PERFORMANCE
-- =========================

SELECT 
    company,
    COUNT(*) AS campaigns,
    AVG(roi) AS avg_roi,
    AVG(conversion_rate) AS avg_conversion,
    SUM(clicks) AS total_clicks
FROM marketing
GROUP BY company
ORDER BY avg_roi DESC;


-- =========================
-- SECTION C: CHANNEL ANALYSIS
-- =========================

SELECT 
    channel_used,
    COUNT(*) AS campaigns,
    AVG(conversion_rate) AS avg_conversion,
    AVG(roi) AS avg_roi,
    SUM(clicks) AS clicks,
    SUM(impressions) AS impressions
FROM marketing
GROUP BY channel_used
ORDER BY avg_roi DESC;


-- =========================
-- SECTION D: CAMPAIGN TYPE PERFORMANCE
-- =========================

SELECT 
    campaign_type,
    COUNT(*) AS campaigns,
    AVG(roi) AS avg_roi,
    AVG(conversion_rate) AS avg_conversion,
    SUM(clicks) AS total_clicks
FROM marketing
GROUP BY campaign_type
ORDER BY avg_roi DESC;


-- =========================
-- SECTION E: AUDIENCE SEGMENTATION
-- =========================

SELECT 
    target_audience,
    AVG(conversion_rate) AS avg_conversion,
    AVG(roi) AS avg_roi,
    SUM(clicks) AS clicks
FROM marketing
GROUP BY target_audience
ORDER BY avg_roi DESC;


-- =========================
-- SECTION F: AGE & GENDER ANALYSIS
-- =========================

SELECT 
    age_group,
    gender,
    COUNT(*) AS campaigns,
    AVG(conversion_rate) AS avg_conversion,
    AVG(roi) AS avg_roi
FROM marketing
GROUP BY age_group, gender
ORDER BY avg_roi DESC;


-- =========================
-- SECTION G: ENGAGEMENT FUNNEL
-- =========================

SELECT 
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2) AS ctr
FROM marketing;


-- =========================
-- SECTION H: COST EFFICIENCY
-- =========================

SELECT 
    campaign_id,
    company,
    acquisition_cost,
    clicks,
    ROUND(acquisition_cost / NULLIF(clicks,0), 2) AS cost_per_click,
    roi
FROM marketing
ORDER BY cost_per_click ASC;


-- =========================
-- SECTION I: MARKET SEGMENT ANALYSIS
-- =========================

SELECT 
    market_segment,
    COUNT(*) AS campaigns,
    AVG(roi) AS avg_roi,
    AVG(conversion_rate) AS avg_conversion
FROM marketing
GROUP BY market_segment
ORDER BY avg_roi DESC;


-- =========================
-- SECTION J: LOCATION ANALYSIS
-- =========================

SELECT 
    location,
    COUNT(*) AS campaigns,
    AVG(roi) AS avg_roi,
    SUM(clicks) AS total_clicks
FROM marketing
GROUP BY location
ORDER BY avg_roi DESC;


-- =========================
-- SECTION K: TIME-BASED TREND
-- =========================

WITH monthly AS (
    SELECT 
        DATE_TRUNC('month', campaign_date) AS month,
        AVG(roi) AS avg_roi,
        SUM(clicks) AS clicks
    FROM marketing
    GROUP BY month
)
SELECT *,
    LAG(avg_roi) OVER (ORDER BY month) AS prev_roi,
    ROUND(
        ( (avg_roi - LAG(avg_roi) OVER (ORDER BY month)) 
           / NULLIF(LAG(avg_roi) OVER (ORDER BY month), 0) * 100
        )::numeric, 2
    ) AS growth_pct
FROM monthly;



-- =========================
-- SECTION L: HIGH PERFORMING CAMPAIGNS
-- =========================

SELECT 
    campaign_id,
    company,
    channel_used,
    campaign_type,
    roi,
    conversion_rate
FROM marketing
WHERE roi > (SELECT AVG(roi) FROM marketing)
ORDER BY roi DESC;


-- =========================
-- SECTION M: CAMPAIGN SEGMENTATION
-- =========================

SELECT *,
    CASE 
        WHEN roi > 5 AND conversion_rate > 0.1 THEN 'High Performers'
        WHEN roi > 3 THEN 'Profitable'
        WHEN roi > 1 THEN 'Break-even'
        ELSE 'Underperforming'
    END AS performance_segment
FROM marketing;



-- ========================
-- INSIGHTS 
-- =========================

-- 1. Overall Performance
-- Strong funnel efficiency with high CTR (~10%) and ROI (~5), indicating profitable campaigns.

-- 2. Company Performance
-- Minimal variation across companies; strategies appear standardized.

-- 3. Channel Performance
-- Facebook and Website perform slightly better; Instagram lags marginally.

-- 4. Campaign Effectiveness
-- Influencer and Search campaigns show slightly higher returns.

-- 5. Audience Insights
-- Men 25–34 generate highest ROI; younger users show higher engagement.

-- 6. Demographics
-- Performance is consistent across genders with no major gaps.

-- 7. Market Segments
-- All segments contribute evenly; weak differentiation in targeting.

-- 8. Geography
-- Minor variation across locations; no strong regional dependency.

-- 9. Trend Analysis
-- ROI fluctuates monthly; peak in September, dip in June.

-- 10. Strategic Insight
-- Stable performance but lacks optimization and targeted strategies.


---------------------END----------------------------



