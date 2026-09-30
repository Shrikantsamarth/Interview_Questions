------------Task:------------
Write a SQL query that returns, for each employee, the following:

1) Their full name and department name
2) Their total sales amount for the year 2024
3) Their rank within their department, based on total sales (highest = rank 1)
4) The department's total sale's
5) Each employee's sales as a percentage of their department's total (rounded to 2 decimal places)
   Filter: Only include employees who made at least 5 sales in 2024.
   Sort the results by department name, then by rank within the department.
  
 ---Expected Output Columns:----
employee_name, department_name, total_sales, dept_rank, dept_total_sales, pct_of_dept

  These are the columns present:
-- Stores information about sales reps
employees (
  employee_id   INT,
  name          VARCHAR,
  department_id INT,
  hire_date     DATE
) 
-- Stores department info
departments (
  department_id INT,
  department_name VARCHAR,
  region        VARCHAR
) 
-- Stores individual sales transactions
sales (
  sale_id       INT,
  employee_id   INT,
  sale_date     DATE,
  amount        DECIMAL
)

--------------------Solution--------------


WITH employee_2024_sales AS (
    -- Step 1: Aggregate total sales and count per employee for 2024
    SELECT 
        e.employee_id,
        e.name AS employee_name,
        d.department_name,
        SUM(s.amount) AS total_sales,
        COUNT(s.sale_id) AS sale_count
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN sales s ON e.employee_id = s.employee_id
    WHERE EXTRACT(YEAR FROM s.sale_date) = 2024
    GROUP BY e.employee_id, e.name, d.department_name
    HAVING COUNT(s.sale_id) >= 5
),
ranked_department_sales AS (
    -- Step 2: Calculate department totals, rank, and percentage share
    SELECT 
        employee_name,
        department_name,
        total_sales,
        DENSE_RANK() OVER (PARTITION BY department_name ORDER BY total_sales DESC) AS dept_rank,
        SUM(total_sales) OVER (PARTITION BY department_name) AS dept_total_sales,
        ROUND((total_sales * 100.0) / SUM(total_sales) OVER (PARTITION BY department_name), 2) AS pct_of_dept
    FROM employee_2024_sales
)
-- Step 3: Select final columns and sort the results
SELECT 
    employee_name,
    department_name,
    total_sales,
    dept_rank,
    dept_total_sales,
    pct_of_dept
FROM ranked_department_sales
ORDER BY department_name ASC, dept_rank ASC;
