create database PizzaHut;
use PizzaHut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL PRIMARY KEY,
    ordre_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL
);

alter table order_details
change ordre_id order_id int not null;

-- Retrieve the total number of orders placed

SELECT 
    COUNT(order_id)
FROM
    orders;
    

-- Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_Sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- Identify the highest-priced pizza

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered

SELECT 
    pizzas.size AS size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY Quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY hour ASC;

-- Join relevant tables to find the category-wise distribution of pizzas

select category ,
count(name) 
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0) AS Average_pizza
FROM
    (SELECT 
        DATE(orders.order_date),
            SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.ordre_id
    GROUP BY order_date) AS order_quantity ;
    

-- Determine the top 3 most ordered pizza types based on revenue
    
SELECT 
    pizza_types.name,
    order_details.quantity * pizzas.price AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
    order by revenue desc limit 3;




-- Calculate the percentage contribution of each pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND((SUM(pizzas.price * order_details.quantity) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS 'Revenue %'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category;



-- Analyze the cumulative revenue generated over time

select order_date,
       round(sum(revenue) over (order by order_date),0) as cum_revenue
       
       from
            (select orders.order_date,
			 sum(order_details.quantity * pizzas.price ) as revenue
            
             from orders join order_details 
             on orders.order_id = order_details.order_id 
			 join pizzas 
             on order_details.pizza_id = pizzas.pizza_id 
             
       group by orders.order_date ) as Sales ;



-- Determine the top 3 most ordered pizza type based on revenue for each pizza category

select name, revenue 
from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn 
from
(select pizza_types.category,
pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by category, name) as a) as b
where rn <= 3 ;

























































