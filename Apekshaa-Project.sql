use film_rental;
show tables;

-- 1. What is the total revenue generated from all rentals in the database? (2 Marks)
select * from payment;
select sum(amount) as Total_revenue from payment;

-- 2. How many rentals were made in each month_name? (2 Marks)
select * from payment;
select monthname(payment_date) as month,count(payment_id) from payment group by month;

-- 3. What is the rental rate of the film with the longest title in the database? (2 Marks)
select * from film;
select title,length(title),rental_rate from film order by length(title) desc limit 1 ;

-- 4. What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)
select * from film;
select * from inventory;
select * from rental;

select f.title,
datediff( r.rental_date,"2005-05-05 22:04:30") as Difference,
avg(f.rental_rate) as avg_rental_date
from film as f
left join inventory as i
on f.film_id=i.film_id
left join rental as r
on r.inventory_id=i.inventory_id
where datediff(r.rental_date,"2005-05-05 22:04:30")<=30
group by 1,2
order by 1;


-- 5. What is the most popular category of films in terms of the number of rentals? (3 Marks)
select * from category;
select * from rental;
select * from film;
select * from film_category;
select * from inventory;

select f.title, c.name, count(rental_id) 
from category as c
join film_category as fc
on c.category_id=fc.category_id
join film as f
on f.film_id=fc.category_id
join inventory as i
on f.film_id=i.film_id
join rental as r
on r.inventory_id=i.inventory_id
group by 1,2 
order by 3 desc limit 1;

-- 6. Find the longest movie duration from the list of films that have not been rented by any customer. (3 Marks)
select * from film;
select * from rental;
select * from inventory;

with long_movie as
(select title,count(r.rental_id) as Rent 
from film as f
left join inventory as i
on f.film_id = i.film_id
left join rental as r
on i.inventory_id = r.inventory_id
group by 1
order by 2 asc)
select f.title,Rent, f.length
from long_movie as l
inner join film as f
on l.title = f.title
having Rent = 0
order by 3 desc
limit 1;

-- 7. What is the average rental rate for films, broken down by category? (3 Marks)
select * from category;
select * from film_category;
select * from film;

select c.name, f.title,avg(f.rental_rate) as avg_rental_rate_films
from category as c
join film_category as fc
on c.category_id=fc.category_id
join film as f
on f.film_id=fc.film_id
group by 1,2;

-- 8. What is the total revenue generated from rentals for each actor in the database? (3 Marks)
select * from actor;
select * from film_actor;
select * from film;

select a.actor_id,a.first_name,sum(f.rental_rate*f.rental_duration) as total_revenue
from actor as a
join film_actor as fa
on a.actor_id=fa.actor_id
join film as f
on fa.film_id=f.film_id
group by 1,2;

-- 9. Show all the actresses who worked in a film having a "Wrestler" in the description. (3 Marks)
select * from actor;
select * from film_actor;
select * from film;

select distinct a.first_name,a.last_name,f.description
from actor as a
join film_actor as fa
on a.actor_id=fa.actor_id
join film as f
on fa.film_id=f.film_id
where f.description like "%Wrestler%";

-- 10. Which customers have rented the same film more than once? (3 Marks)
select * from customer;
select * from rental;
select * from inventory;

select c.first_name,c.last_name, f.title, count(f.title) as Times_rented
from customer as c
join rental as r
on c.customer_id =r.customer_id
join inventory as i
on r.inventory_id = i.inventory_id
join film as f
on i.film_id = f.film_id
group by 1,2,3
having Times_rented>1
order by Times_rented desc ;

-- 11. How many films in the comedy category have a rental rate higher than the average rental rate? (3 Marks)
select * from category;
select * from film_category;
select * from film;


select c.name,count(distinct f.film_id) as 'Total films'
from category as c
join film_category as fc
on c.category_id=fc.category_id
join film as f
on fc.film_id=f.film_id
where rental_rate > (select avg(rental_rate) from film)
and c.name like '%comedy%'
group by 1;

-- 12. Which films have been rented the most by customers living in each city? (3 Marks)
select * from customer;
select * from address;
select * from rental;
select * from city;
select * from inventory;
select * from film;

with m_rented as
(select f.city, d.title, count(d.title) as Times_rented,
row_number() over(partition by f.city) as Most_rented
from customer a
inner join rental b
on a.customer_id =b.customer_id
left join inventory c
on b.inventory_id = c.inventory_id
left join film d
on c.film_id = d.film_id
left join address e
on e.address_id = a.address_id
left join city f
on f.city_id = e.city_id
group by 1,2)
select distinct city, title, Times_rented
from m_rented
where Most_rented = 1
order by Times_rented desc;

-- 13. What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)
select * from payment;
select * from customer;

select p.customer_id,c.first_name,c.last_name,sum(p.amount) as Total_amount
from customer as c
join payment as p
on c.customer_id=p.customer_id
group by c.customer_id
having Total_amount >200;

-- 14. Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema] (2 Marks)
select * from rental;

select  inventory_id, customer_id, staff_id
from rental
group by 1,2,3
order by 1,2 desc;

-- 15. Create a View for the total revenue generated by each staff member, broken down by store city with the country name. (4 Marks)
select * from store;
select * from address;
select * from city;
select * from country;
select * from staff;
select * from payment;

create view total_revenue as
select  c.city,d.country, e.first_name, e.last_name, sum(amount) as revenue
from store a
join address b
on a.address_id = b.address_id
join city c
on b.city_id = c.city_id
join country d
on c.country_id = d.country_id
join staff e
on a.store_id = e.store_id
join payment f
on e.staff_id = f.staff_id
group by 1,2,3,4;

select * from total_revenue;

-- 16. Create a view based on rental information consisting of visiting_day, customer_name, the title of the film, 
-- no_of_rental_days, the amount paid by the customer along with the percentage of customer spending. (4 Marks)
select * from customer;
select * from rental;
select * from payment;
select * from inventory;
select * from film;

create view rental_information as
select r.rental_date as visiting_day, 
c.first_name, c.last_name, f.title, 
datediff(r.return_date,r.rental_date)  as no_of_rental_days, 
p.amount, 
round(p.amount/(sum(p.amount) over(partition by c.first_name ))*100,2) as Percentage_spent
from customer as c
inner join rental as r
on c.customer_id = r.customer_id
inner join payment as p
on r.rental_id = p.rental_id
inner join inventory as i
on r.inventory_id = i.inventory_id
inner join film as f
on i.film_id = f.film_id 
having no_of_rental_days is not null ;

select * from rental_information;

-- 17. Display the customers who paid 50% of their total rental costs within one day
select * from payment;

with rental as 
(
select payment_date,customer_id,sum(amount) amount 
from payment 
group by 1,2 
),

Total_rental as
(
select payment_date,customer_id, amount, sum(amount) over (partition by customer_id) total_amount 
from Rental
) 

select * from Total_rental
where amount/total_amount >= 0.5 ; 


