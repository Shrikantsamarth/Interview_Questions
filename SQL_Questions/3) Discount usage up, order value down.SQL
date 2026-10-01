Master schema (reference)
Table	        Columns	Grain 
customers	    customer_id, name, email, segment, signup_date, updated_at	              (customer version)
products	    product_id, product_name, category	                                      (product)

orders	      order_id, customer_id, order_date, status, order_value, discount_pct      (order)
order_items	  order_id, product_id, quantity, unit_price	                              (order line)

events	      event_id, session_id, customer_id, event_type, event_ts	                  (event)


------------------Solution------------------------

Q3. Discount usage up, order value down

With Customer1 AS(
Select customer_id,
 AVG(CASE WHEN Order_date >= DATEADD(day, -90, CURRENT_DATE) THEN discount_pct) AS discount_recent,
 AVG(CASE WHEN Order_date < DATEADD(day, -90, CURRENT_DATE) THEN discount_pct) AS discount_prior,
AVG(CASE WHEN Order_date >= DATEADD(day, -90, CURRENT_DATE) THEN order_value) AS aov_recent,
AVG(CASE WHEN Order_date >= DATEADD(day, -90, CURRENT_DATE) THEN order_value) AS aov_recent
From Orders
Where Order_date >= DATEADD(day, -180, CURRENT_DATE)
Group by 1
)

SELECT * FROM Customer1
Where Discount_recent > Discount_prior AND aov_recent < aov_prior;



--------------Practice------------------

Q3. Discount usage up, order value down


With Cust As( 
    Select customer_id,
        Avg(CASE When Order_date >= DATEADD(Day, -90, CURRENT_DATE) THEN discount_pct END) AS Disc_recent,
        Avg(CASE When Order_date < DATEADD(Day, -90, CURRENT_DATE) THEN discount_pct END) AS Disc_prior,
        Avg(CASE When Order_date >= DATEADD(Day, -90, CURRENT_DATE) THEN order_value END) AS aov_recent, 
         Avg(CASE When Order_date < DATEADD(Day, -90, CURRENT_DATE) THEN order_value END) AS aov_prior
    From Orders
    Where Order_date >= DATEADD(Day, -180, CURRENT_DATE)
    Group By 1
)

Select * from Cust
Where disc_recent > disc_prior AND aov_recent < aov_prior;

