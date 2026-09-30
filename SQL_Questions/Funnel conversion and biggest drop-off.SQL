Master schema (reference)
Table	        Columns	Grain 
customers	    customer_id, name, email, segment, signup_date, updated_at	              (customer version)
products	    product_id, product_name, category	                                      (product)
orders	      order_id, customer_id, order_date, status, order_value, discount_pct      (order)
order_items	  order_id, product_id, quantity, unit_price	                              (order line)
events	      event_id, session_id, customer_id, event_type, event_ts	                  (event)



Q2. Funnel conversion and biggest drop-off

Journey of a customer on website: product_view, Add to cart, checkout, purchase 

Select 
COUNT (DISTINCT IFF(Event_type = 'product_view', Session_id, Null)) As views,
COUNT (DISTINCT IFF(Event_type = 'Add_to_cart', Session_id, Null)) As Cart,
COUNT (DISTINCT IFF(Event_type = 'Checkout', Session_id, Null)) As Chcekouts,
COUNT (DISTINCT IFF(Event_type = 'purchase', Session_id, Null)) As purchases,
From events;


Then the step rates are just division: carts ÷ views, checkouts ÷ carts, purchases ÷ checkouts. The lowest one is the biggest drop-off.
