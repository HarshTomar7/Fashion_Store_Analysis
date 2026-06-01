# 👗 Fashion E-Commerce Sales Analysis
**SQL + Power BI &nbsp;|&nbsp; Harsh Singh Tomar**

---

## The Problem

A fashion and lifestyle online store had a strong start in 2023. Revenue peaked at $329K in January 2024 — then fell every single month after that, ending at just $27K by December 2024.

The business needed to understand:
- **Why did the peak not hold after January 2024?**
- **Is the problem retention, acquisition, or something else?**
- **Which categories and markets are actually growing?**
- **Who are the most valuable customers and are they still active?**

I analysed 50,000 transactions from ~4,000 customers across 10 markets to find the answers.

---

## The Data

Each row is one purchase from the store. It tells us:
- Who bought, when, and how much they spent
- Which product category and which country
- Their age group and payment method

**Dataset:** 50,000 transactions · ~4,000 customers · Jan 2023 – Dec 2024 · 10 countries · 7 product categories

---

## What I Did — Step by Step

### Step 1 — Start with the headline numbers
> **$4.09M total revenue · 50K orders · ~4,000 customers · $82 avg order value**

Revenue per customer is $1,020 — much higher than typical because most customers keep coming back. So why is revenue falling?

---

### Step 2 — Map the revenue trend month by month
I used `LAG()` to calculate month-over-month change and found a clear pattern:

| Period | What happened |
|--------|--------------|
| Jan–Mar 2023 | Strong start — $208K to $270K |
| Jun–Aug 2023 | Summer slump — dropped to $78K |
| Oct–Dec 2023 | Recovery — back to $288K |
| Jan 2024 | All-time peak — $329K |
| Feb–Dec 2024 | Fell every single month — ended at $27K |

> The store hit its peak and then couldn't hold it. New customer acquisition stopped after January 2024.

---

### Step 3 — Is it a retention problem or an acquisition problem?
This was the key question. If customers aren't coming back, fix retention. If they are coming back but revenue is still falling, fix acquisition.

> **Repeat rate = 87.7%.** Only 12.3% of customers bought once and left.

This store actually has *excellent* retention — far better than average ecommerce. The 2024 decline is purely an **acquisition problem.** The loyal base kept buying, but no new customers were coming in to grow the pool.

---

### Step 4 — Which categories are driving revenue?
> Fashion = 31.4% · Footwear = 24.3% · Skincare = 15.7%
> Top 3 categories = 71.4% of all revenue

Bags have the **highest average order value ($140)** but contribute only 5% of revenue — they're being underinvested. Footwear is also high AOV ($110) and already the #2 category.

---

### Step 5 — Who are the best customers?
> Top customer: David Martinez — 64 orders, $5,488 spent

The top customers aren't one-time big spenders — they're frequent buyers who keep coming back. This confirms the retention story: the loyal base is strong, but it's not growing.

---

### Step 6 — Which markets matter most?

| Country | Revenue | Type |
|---------|---------|------|
| Indonesia | $815K | Priority |
| Vietnam | $626K | High volume |
| Philippines | $610K | High volume |
| Singapore | $323K | High value (highest AOV) |
| UAE | $168K | Growth — high AOV |
| Japan | $118K | Growth — high AOV |

> Singapore, UAE, and Japan have high average order values but low volume — they're underserved premium markets worth targeting.

---

### Step 7 — What's the seasonal pattern?
> Jan–Mar and Oct–Dec are the strongest months every year.
> Jun–Aug is consistently weak — the "summer slump."

The store should plan its biggest campaigns and new product launches around these peak windows, and use the slow months for retention activities.

---

## Dashboard

### Page 1 — Business Performance
<img width="1285" height="727" alt="Page_1" src="https://github.com/user-attachments/assets/1eeccc99-9a00-42cc-baf7-94036692b343" />


Revenue totals, monthly trend (peak + decline visible), category breakdown, age group, payment method split.

### Page 2 — Customer Intelligence
<img width="1299" height="724" alt="Page_2" src="https://github.com/user-attachments/assets/dd78a2a2-9b3d-4bfd-91d0-c3a60e9cd30a" />


Repeat rate, CLV, country revenue, customer segments, top customers table, and recommendations.

---

## What I Found

**The store has a great product but a growth problem.**

| Finding | What it means |
|---------|--------------|
| Revenue peaked Jan 2024, fell 12 months straight | Acquisition pipeline dried up |
| 87.7% repeat rate | Retention is strong — not the problem |
| Bags have highest AOV but only 5% revenue share | Underinvested premium category |
| Singapore, UAE, Japan = high AOV but low volume | Untapped premium markets |
| Jun–Aug consistently weak | Predictable seasonal slump needs a plan |

---

## What I'd Recommend

**Invest in new customer acquisition**
The loyal base is healthy. The store needs new people entering the funnel — paid social, influencer collabs, or referral programs.

**Push the Bags category harder**
Highest AOV at $140. If Bags grew from 5% to 12% revenue share, that adds hundreds of thousands in revenue without needing new customers.

**Target Singapore, UAE, and Japan for premium products**
These markets spend more per order. A focused campaign for Bags and Footwear in these countries would be high ROI.

**Plan around the seasonal calendar**
Use Jan–Mar and Oct–Dec for new launches and acquisition. Use Jun–Aug for loyalty rewards and retention to hold the base through the slump.

**Grow Buy Now Pay Later for high-ticket items**
BNPL is at 8.1% but likely drives higher AOV purchases. Push it at checkout for Bags, Footwear, and Sportswear.

---

## What I Learned

- How to use `LAG()` to track month-over-month growth and spot turning points
- How to distinguish between a retention problem and an acquisition problem using data
- How `NTILE()` and `CASE WHEN` work together for customer segmentation
- How to think about AOV and revenue share together — not just which category earns most, but which is *underpunching*
- How seasonal patterns show up in data and why they matter for planning

---

## What I'd Do Next

- Build a proper cohort chart to see exactly when 2024 new customers dropped off
- Segment BNPL users separately to confirm the AOV hypothesis
- Map seasonal revenue patterns against marketing spend to find the most efficient windows

---

## Tools

| Tool | Used For |
|---|---|
| PostgreSQL | 10 queries covering the full story |
| Power BI | Dashboard, charts, KPI cards |
| DAX | Calculated measures (repeat rate, CLV, revenue share) |
| Python | Dataset generation |

---

## Files

```
├── fashion_ecommerce_analysis.sql   → 10 queries that walk through the full story
├── ecommerce_fashion.csv            → Generated dataset (50,000 rows)
├── README.md                        → This file
├── page_1.png                       → Dashboard page 1
└── page_2.png                       → Dashboard page 2
```

---

*Personal learning project by Harsh Singh Tomar*
