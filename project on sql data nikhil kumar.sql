drop database project;
create database project;
use project;

create table employee(
employee_id int primary key,
last_name varchar(100),
first_name varchar(100),
title varchar(100),
reports_to int,
levels varchar(100),
birthdate varchar(100),
hire_date varchar(100),
address varchar(100),
city varchar(100),
state varchar(100),
country varchar(100),
postal_code varchar(100),
phone varchar(100),
fax varchar(100),
email varchar(100)
);

desc employee;
select * from employee;

create table customer(
customer_id int primary key,
first_name varchar(100),
last_name varchar(100),
company varchar(100),
address varchar(100),
city varchar(100),
state varchar(100),
country varchar(100),
postal_code varchar(100),
phone varchar(100),
fax varchar(100),
email varchar(100),
support_rep_id int not null,
FOREIGN KEY (support_rep_id)
REFERENCES employee (employee_id)  ON DELETE CASCADE ON UPDATE CASCADE);

select * from customer;

create table invoice(
invoice_id int primary key,
customer_id int not null,
invoice_date varchar(30),
billing_address varchar(40),
billing_city varchar(40),
billing_state varchar(40),
billing_country varchar(40),
billing_postal_code varchar(40),
total float,
FOREIGN KEY (customer_id)
REFERENCES customer (customer_id)  ON DELETE CASCADE ON UPDATE CASCADE);

select * from invoice;


create table artist(
artist_id int primary key,
name varchar(100));

select * from artist;

create table playlist(
playlist_id int primary key,
name varchar(100));


select * from playlist;

create table genre(
genre_id int primary key,
name varchar(100));

select * from genre;

create table media_type(
media_type_id int primary key,
name varchar(100));

create table track(
track_id int primary key,
name varchar(100),
album_id int not null,
media_type_id int not null,
genre_id int not null,
composer varchar(100),
milliseconds int,
bytes int,
unit_price float,
FOREIGN KEY (media_type_id)
REFERENCES media_type (media_type_id)  ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (genre_id)
REFERENCES genre (genre_id)  ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (album_id)
REFERENCES album (album_id)  ON DELETE CASCADE ON UPDATE CASCADE);


create table Playlist_track(
playlist_id int not null,
track_id int not null,
FOREIGN KEY (playlist_id)
REFERENCES playlist (playlist_id)  ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (track_id)
REFERENCES track (track_id)  ON DELETE CASCADE ON UPDATE CASCADE);


select * from playlist_track;

create table album(
album_id int primary key,
title varchar(200),
artist_id int not null,
FOREIGN KEY (artist_id)
REFERENCES artist (artist_id)  ON DELETE CASCADE ON UPDATE CASCADE);

select * from album;


create table invoice_line(
invoice_line_id int primary key,
invoice_id int not null,
track_id int not null,
unit_price float,
quantity int,
FOREIGN KEY (invoice_id)
REFERENCES invoice (invoice_id)  ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (track_id)
REFERENCES track (track_id)  ON DELETE CASCADE ON UPDATE CASCADE);


/-- Question Set 1 - Easy
/-- Who is the senior most employee based on job title?
select concat(first_name,'',last_name) as name ,title from employee
order by levels desc
limit 1;

/-- type 2

select concat(first_name,'',last_name) as name from employee
where title =(select max(title) from employee);

/--  Which countries have the most Invoices?

SELECT billing_country,max(total) as total_invoice from invoice
group by billing_country;


/-- What are top 3 values of total invoice?

select * from invoice;
select total from invoice
order by total desc
limit 3;

/* Which city has the best customers? We would like to throw a promotional
Music Festival in the city we made the most money. Write a query that
returns one city that has the highest sum of invoice totals. Return both the
city name & sum of all invoice totals*/

select * from invoice;
select distinct billing_city,round(sum(total),2) as total from invoice
group by billing_city
order by total desc
limit 1;


/* Who is the best customer? The customer who has spent the most money will
be declared the best customer. Write a query that returns the person who
has spent the most money*/

select first_name,last_name from customer
where customer_id =(select customer_id from invoice group by customer_id  order by sum(total) desc limit 1);

select customer_id,sum(total) from invoice group by customer_id  order by sum(total) desc;

/-- Question Set 2 – Moderate
/*• Write query to return the email, first name, last name, & Genre of all Rock
Music listeners. Return your list ordered alphabetically by email starting with
A*/

 SELECT distinct email,customer.first_name,customer.last_name,genre.name
 FROM customer
 JOIN invoice using (customer_id)
 JOIN invoice_line using (invoice_id)
 JOIN track using (track_id)
 JOIN genre using (genre_id)
 WHERE genre.name="rock" and customer.email like "a%"
 ORDER BY email ASC;

/*Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the Artist name and total track count of the top 10
rock bands*/

select distinct artist.name,count(*) as count,genre.name from artist
join album using (artist_id)
join track using (album_id)
join genre  using (genre_id)
where  genre.name='Rock'
group by artist.artist_id 
order by count desc
limit 10;

/*• Return all the track names that have a song length longer than the average
song length. Return the Name and Milliseconds for each track. Order by the
song length with the longest songs listed first*/

select avg(milliseconds) from track;

select name,milliseconds from track where milliseconds > (select avg(milliseconds) from track) order by milliseconds desc;

/-- Question Set 3 – Advance
/* Find how much amount spent by each customer on artists? Write a query to
return customer name, artist name and total spent */

select distinct concat(customer.first_name,'',customer.last_name) as cust_name,artist.name as artist_name,(invoice_line.unit_price*invoice_line.quantity) as total_spent from artist
join album using (artist_id)
join track using (album_id)
join invoice_line using (track_id)
join invoice using (invoice_id)
join customer using (customer_id);

/*We want to find out the most popular music Genre for each country. We
determine the most popular genre as the genre with the highest amount of
purchases. Write a query that returns each country along with the top Genre
For countries where the maximum number of purchases is shared return all
Genres*/

with cte as(select c.country,concat(c.first_name,' ',c.last_name) as customer_name,sum(il.unit_price*il.quantity) as top_spent
from customer c 
join invoice using (customer_id)
join invoice_line il using (invoice_id)
group by c.customer_id, c.country)
select country,customer_name,top_spent from cte
where (country,top_spent) in (select country,max(top_spent) as max_spent from cte group by country)
order by country;


/*Write a query that determines the customer that has spent the most on
music for each country. Write a query that returns the country along with the
top customer and how much they spent. For countries where the top amount
spent is shared, provide all customers who spent this amoun*/


with cte2 as(select g.name as Popular_genre,c.country,sum(il.quantity) as purchases
from customer c 
join invoice i using (customer_id)
join invoice_line il using (invoice_id)
join track t using (track_id)
join genre g using (genre_id)
group by g.name,c.country
order by c.country ,purchases desc)
select country,coalesce(max(popular_genre),'unknown') as max_purchases from cte2
group by country;
