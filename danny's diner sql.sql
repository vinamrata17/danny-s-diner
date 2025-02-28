--link: https://8weeksqlchallenge.com/case-study-1/

--What is the total amount each customer spent at the restaurant?
select sales.customer_id,sum(menu.price) as total_amount_spent from sales
join menu
	on sales.product_id=menu.product_id
group by sales.customer_id
	order by customer_id 


--How many days has each customer visited the restaurant?
	select customer_id,count(distinct order_date) as times_visited
	from sales
	group by customer_id

	
--What was the first item from the menu purchased by each customer?
with cte as(
select customer_id,menu.product_name,order_date,
rank()over(partition by customer_id order by order_date) as rank,
row_number()over(partition by customer_id order by order_date) as rn
	from sales
join menu
	on sales.product_id=menu.product_id
	 )
	select customer_id,product_name,rank,rn
	from cte where rn=1
	

	
--What is the most purchased item on the menu and how many times was it purchased by all customers?

	select menu.product_name,count(order_date) as cn from sales
join menu
	on sales.product_id=menu.product_id
group by menu.product_name
	limit 1
	

--Which item was the most popular for each customer?
	with cte as ( select sales.customer_id, menu.product_name,
	count(order_date) as orders ,
rank()over(partition by customer_id order by count(order_date)) as rnk,
row_number()over(partition by customer_id order by count(order_date)) as rn
	from sales
join menu
	on sales.product_id=menu.product_id
group by menu.product_name,sales.customer_id)
	select * from cte
	where rn=1

--Which item was purchased first by the customer after they became a member?
	
with cte as (select sales.customer_id,order_date,menu.product_name,members.join_date,
rank()over(partition by sales.customer_id order by order_date) as rnk,
row_number()over(partition by sales.customer_id order by order_date) as rn
		from sales
join menu
	on sales.product_id=menu.product_id
	join members
	on sales.customer_id=members.customer_id
	where sales.order_date>=members.join_date)
select * from cte
	where rn=1


--Which item was purchased just before the customer became a member?
with cte as (select sales.customer_id,order_date,menu.product_name,members.join_date,
rank()over(partition by sales.customer_id order by order_date desc) as rnk,
row_number()over(partition by sales.customer_id order by order_date desc) as rn
		from sales
join menu
	on sales.product_id=menu.product_id
	join members
	on sales.customer_id=members.customer_id
	where sales.order_date<members.join_date)
select * from cte
	where rnk=1


	
--What is the total items and amount spent for each member before they became a member?

select sales.customer_id,sum(price) as spent,count(product_name)
		from sales
	inner join menu on sales.product_id=menu.product_id
	inner join members on sales.customer_id=members.customer_id
	where sales.order_date<members.join_date
	group by sales.customer_id
	order by customer_id