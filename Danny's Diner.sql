CREATE SCHEMA dannys_diner;

USE dannys_diner;


CREATE TABLE menu (
product_id INT NOT NULL,
product_name VARCHAR(5),
price INT,
PRIMARY KEY (product_id)
);

INSERT INTO menu (product_id, product_name, price)
VALUES 
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');


CREATE TABLE members (
customer_id VARCHAR(1) NOT NULL,
join_date DATE,
PRIMARY KEY (customer_id)
);

INSERT INTO members (customer_id, join_date)
VALUES 
('A', '2021-01-07'),
('B', '2021-01-09');

CREATE TABLE sales (
customer_id VARCHAR(1) NOT NULL,
order_date DATE,
product_id INT NOT NULL
);

INSERT INTO sales (customer_id, order_date, product_id)
VALUES 
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');




 #Questions
 #(1) What is the total amount each customer spent at the restaurant?
  SELECT customer_id, SUM(price) as Amount_spent
  FROM sales
  LEFT JOIN menu ON sales.product_id = menu.product_id
  GROUP BY customer_id;

 #(2) How many days has each customer visited the restaurant?
 SELECT customer_id, COUNT(DISTINCT(order_date)) as number_of_visits
 FROM sales
 GROUP BY customer_id;

 #(3) What was the first item from the menu purchased by each customer?
 SELECT MIN(order_date) as earliest_date
 FROM sales;

 SELECT customer_id, product_name, order_date
 FROM sales
 LEFT JOIN menu ON sales.product_id = menu.product_id
 WHERE order_date = '2021-01-01'
 GROUP BY customer_id;

#(4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, count(product_name) as times_purchased
FROM sales
LEFT JOIN menu on sales.product_id = menu.product_id
GROUP BY product_name
order by times_purchased DESC
limit 1;

#(5) Which item was the most popular for each customer?
SELECT customer_id, product_name, COUNT(product_name) as times_purchased
FROM sales
LEFT JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id, product_name
ORDER BY times_purchased DESC;

#(6)  Which item was purchased first by the customer after they became a member?
-- Customer A
SELECT customer_id, order_date, product_name 
FROM sales 
LEFT JOIN menu ON sales.product_id = menu.product_id
WHERE customer_id = 'A' AND order_date > '2021-01-07' -- date after membership
ORDER BY order_date
LIMIT 1;

-- Customer B
SELECT customer_id, order_date, product_name 
FROM sales
LEFT JOIN menu ON sales.product_id = menu.product_id
WHERE customer_id = 'B' AND order_date > '2021-01-09' -- date after membership
ORDER BY order_date
LIMIT 1;

#(7)  Which item was purchased just before the customer became a member?
-- Customer A
SELECT customer_id, order_date, product_name 
FROM sales 
LEFT JOIN menu ON sales.product_id = menu.product_id
WHERE customer_id = 'A' AND order_date < '2021-01-07'; -- date before membership
-- Customer B
SELECT customer_id, order_date, product_name 
FROM sales
LEFT JOIN menu ON sales.product_id = menu.product_id
WHERE customer_id = 'B' AND order_date < '2021-01-09' -- date before membership
ORDER BY order_date DESC
LIMIT 1;

#(8) What are the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(s.product_id) AS total_items, SUM(m.price) AS total_amount_spent
FROM sales AS s
JOIN members AS mm ON s.customer_id = mm.customer_id
JOIN menu AS m ON s.product_id = m.product_id
WHERE s.order_date < mm.join_date
GROUP BY s.customer_id;

#(9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
SELECT customer_id, 
SUM(CASE WHEN product_name = 'sushi' THEN 20 * price
    ELSE 10 * price
END)  total_points
FROM sales
LEFT JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;

#(10) If the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customers A and B have at the end of January?
SELECT sales.customer_id,
  SUM(CASE WHEN order_date <= DATE_ADD(join_date, INTERVAL 6 DAY) THEN menu.price * 2
    ELSE menu.price
  END) AS total_points
FROM sales
JOIN members ON sales.customer_id = members.customer_id
JOIN menu ON sales.product_id = menu.product_id
WHERE YEAR(order_date) = 2021 AND MONTH(order_date) = 1
GROUP BY sales.customer_id;