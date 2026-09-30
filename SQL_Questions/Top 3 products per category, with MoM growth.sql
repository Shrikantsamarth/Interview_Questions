Master schema (reference)
Table	        Columns	Grain 
customers	    customer_id, name, email, segment, signup_date, updated_at	              (customer version)
products	    product_id, product_name, category	                                      (product)
orders	      order_id, customer_id, order_date, status, order_value, discount_pct      (order)
order_items	  order_id, product_id, quantity, unit_price	                              (order line)
events	      event_id, session_id, customer_id, event_type, event_ts	                  (event)


1Q) Top 3 products per category, with MoM growth

WITH m As (
Select 
p.product_id,
p.Category, 
Date_Truncate('Month', o.order_date) As Month,
Sum(oi.Quantity * oi.unit_price) - o.Discount_pct As Revenue
From Orders_items oi
Left Join Orders o on o.order_id  = oi.order_id
Left Join Products p on p.product_id = oi.product_id
Group By 1,2,3
)
---Rank, Mom growth
Select *,
 Rank() Over (Partition by Category, month Order By Revenue Desc) AS Rnk
 Revenue / LAG(revenue) Over (Partition By product_id Order By Month) - 1 AS MoM_growth
 From m

 QUALIFY rnk<=3;
