# Key Findings — Grocery Store Management SQL Analysis

Analysis based on 300 orders, 200 customers, 50 products, 5 suppliers, and 10 employees
loaded into `grocery_store_management_db`.

## 1. Customer Insights
- 156 of 200 registered customers (78%) have placed at least one order.
- Order frequency has a long tail: most active customers ordered 1–3 times; only a
  handful (e.g. Jyotika, 7 orders) are frequent repeat buyers.
- **Order frequency and order value are different growth levers.** The customer with
  the most orders (Jyotika, 7 orders, ₹632.99 avg) is not the top spender. The top
  spender, Chetan Naidu (₹11,256.82 total), ranks lower on order count.
- Top 5 customers by total spend: Chetan Naidu (₹11,256.82), Kapila (₹11,099.51),
  Eshwar Rao (₹10,819.96), Aditi Rao (₹10,230.64), Eshwar Iyer (₹9,188.45).

## 2. Product Performance
- Grains & Cereals (18 SKUs) and Snacks & Confectioneries (17 SKUs) make up 70% of
  the catalog, but carry the *lowest* average prices (₹287.67 / ₹278.89).
- Dairy, Personal Care, and Household are smaller categories (3–6 SKUs each) but
  carry the highest average prices (₹363–367).
- **Volume leader ≠ revenue leader.** Bath Soap sells the most units (60) but ranks
  ~18th in revenue. Hand Sanitizer sells nearly as many units (56) but is the
  #1 product by revenue (₹27,787.76) due to its higher price point.
- Personal Care (only 6 SKUs) contains both the volume leader and the revenue
  leader — a small category with outsized impact.

## 3. Sales & Order Trends
- 300 total orders, ₹2,153.63 average order value (~₹646K total revenue).
- No single date stands out — busiest individual days peak at only 4 orders.
- Clear monthly seasonality: **January (₹70,312) and December (₹60,903) are the
  strongest months**; April and October are troughs (11–12 orders, ~₹27–29K),
  roughly a third of January's volume.
- Weekday vs. weekend split (183 vs. 73 orders, ~71/29) roughly matches the
  5-day/2-day calendar split — **not a meaningful behavioral pattern.** Average
  order value is also nearly flat across the two (₹2,136 vs ₹2,197).

## 4. Supplier Contribution
- Only 5 suppliers total — a concentrated supply base.
- **Aarya dominates on every axis**: most products (18), highest revenue
  (₹221,137.83) — roughly double the #2 supplier, Sai (₹113,588.51).
- Aarya + Sai together account for roughly two-thirds of total supplier revenue.
  Aarav Sharma trails at ₹33,052.85, about 1/7th of Aarya's contribution.
- Average price per supplier is flat (₹271–343) — Aarya's lead comes from product
  count and volume, not premium pricing. This is a supply concentration risk, not
  a pricing story.

## 5. Employee Performance
- All 10 employees have processed orders.
- Order count and total sales don't align perfectly: Diya Sharma 1 handles the
  most orders (38) but Aditya Singh 1 generates the most revenue (₹79,252.29)
  with one fewer order.
- **Aarav Kumar 1 is an efficiency outlier**: 2nd-lowest order count (23) but the
  highest average order value (₹1,073.53) of any employee.
- Aditya Verma 1 is the weak spot: lowest total sales (₹34,204.51) and lowest
  average order value (₹760.10) despite a mid-pack order count — a per-order-size
  issue, not a volume issue.
- Top performer generates ~2.3x the total sales of the bottom performer.

## 6. Order Details Deep Dive
- Quantity scales price near-linearly (qty 1 → ₹319.27, qty 5 → ₹1,530.40) —
  no bulk-discount pricing logic in this dataset.
- Every product was sold at a single fixed price (min = max = avg `each_price`
  per product) — no promotions or price changes over the year.
- Average quantity per order line ranges narrowly (1.64–4.56). Butter has the
  highest average quantity per order (4.56) despite being a mid-tier revenue
  product — customers buy more of it per purchase than almost anything else.

## Summary Table

| Section | Standout finding |
|---|---|
| Customer Insights | Order frequency and order value are different growth levers |
| Product Performance | Bath Soap wins on volume, Hand Sanitizer wins on revenue |
| Sales Trends | Jan/Dec seasonal peak, Apr/Oct trough; weekday/weekend split isn't meaningful |
| Supplier Contribution | Aarya alone drives ~34% of total revenue — concentration risk |
| Employee Performance | Aarav Kumar 1: fewer orders, highest value-per-order |
| Order Details | Fixed pricing (no discounts); quantity scales linearly with price |
