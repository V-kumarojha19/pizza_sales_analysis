use pizza_sales;

-- BASIC:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    pizzas p
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT 
    pt.name
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size AS most_common_size
FROM
    pizzas p
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY SUM(od.quantity) DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS most_ordered_types
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY SUM(od.quantity) DESC
LIMIT 5;


-- INTERMEDIATE:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
	pt.category, SUM(od.quantity) AS total_ordered_quantity
FROM pizza_types pt
		INNER JOIN
	pizzas p ON p.pizza_type_id = pt.pizza_type_id
		INNER JOIN 
	order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY SUM(od.quantity) DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(time) AS hour, COUNT(order_id) AS no_of_orders FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pt.category, SUM(quantity) AS no_of_orders
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY no_of_orders;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    o.date, AVG(od.quantity) AS daily_avg_orders
FROM
    orders o
        INNER JOIN
    order_details od ON od.order_id = o.order_id
GROUP BY 1
ORDER BY 1;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- ADVANCED:

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.name,
    ROUND(ROUND(SUM(od.quantity * p.price), 2) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2)
                FROM
                    order_details od
                        INNER JOIN
                    pizzas p ON p.pizza_id = od.pizza_id) * 100,
            2) AS revenue_percentage
FROM
    pizza_types pt
        INNER JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        INNER JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY 1;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

WITH ranked_pizzas AS (
	SELECT pt.category,
		pt.name,
        ROUND(SUM(od.quantity * p.price),2) AS revenue,
        RANK() OVER(PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS pizza_rank
	FROM pizza_types pt
		INNER JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
		INNER JOIN order_details od ON od.pizza_id = p.pizza_id
	GROUP BY 1,2)

SELECT * from ranked_pizzas
WHERE pizza_rank <= 3;


-- Analyze the cumulative revenue generated over time.
WITH cum_sum AS (
	SELECT o.date, ROUND(SUM(p.price * od.quantity),2) AS revenue
    FROM orders o
		INNER JOIN order_details od ON od.order_id = o.order_id
		INNER JOIN pizzas p ON p.pizza_id = od.pizza_id
	GROUP BY o.date
)
SELECT date, revenue, ROUND(SUM(revenue) OVER(ORDER BY date),2) AS cumulative_sum
FROM cum_sum;