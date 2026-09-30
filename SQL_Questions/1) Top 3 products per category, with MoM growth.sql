Master schema (reference)
Table	        Columns	Grain 
customers	    customer_id, name, email, segment, signup_date, updated_at	              (customer version)
products	    product_id, product_name, category	                                      (product)
orders	      order_id, customer_id, order_date, status, order_value, discount_pct      (order)
order_items	  order_id, product_id, quantity, unit_price	                              (order line)
events	      event_id, session_id, customer_id, event_type, event_ts	                  (event)


1Q) Top 3 products per category, with MoM growth

 -----------Solution 1----------------
WITH m AS (
  SELECT p.category, p.product_id,
         DATE_TRUNC('month', o.order_date) AS month,
         SUM(oi.quantity * oi.unit_price) AS revenue
  FROM order_items oi
  JOIN orders o   ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  GROUP BY 1, 2, 3
)
SELECT *,
       RANK() OVER (PARTITION BY category, month ORDER BY revenue DESC) AS rnk,
       revenue / LAG(revenue) OVER (PARTITION BY product_id ORDER BY month) - 1 AS mom_growth
FROM m
QUALIFY rnk <= 3;


----Solution 2---------------

WITH monthly AS (
  SELECT p.category, p.product_id,
         DATE_TRUNC('month', o.order_date) AS month,
         SUM(oi.quantity * oi.unit_price - oi.discount_amt) AS revenue
  FROM order_items oi
  JOIN orders o   ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.status = 'completed'
  GROUP BY 1, 2, 3
),
growth AS (
  SELECT *,
         LAG(revenue) OVER (PARTITION BY product_id ORDER BY month) AS prev_rev
  FROM monthly
),
ranked AS (
  SELECT *,
         (revenue - prev_rev) / NULLIF(prev_rev, 0) AS mom_growth,
         RANK() OVER (PARTITION BY category, month ORDER BY revenue DESC) AS rnk
  FROM growth
)
SELECT * FROM ranked WHERE rnk <= 3;
