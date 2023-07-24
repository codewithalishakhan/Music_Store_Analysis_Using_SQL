
use Music_Store_Analysis;

SELECT * FROM customer
SELECT * FROM invoice
SELECT * FROM invoice_line
SELECT * FROM media_type
SELECT * FROM employee



/* Q1: Who is the senior most employee based on job title? */

SELECT  top 1 last_name,first_name,title 
from employee
ORDER BY levels desc


/* Q2: Which countries have the most Invoices? */
SELECT * FROM invoice;

SELECT COUNT(*) as c,billing_country
from invoice
group by billing_country
order by c desc;



/* Q3: What are top 3 values of total invoice? */

SELECT * FROM invoice;

SELECT  top 3 total 
FROM invoice
ORDER BY total DESC;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT * FROM invoice;


SELECT  top 1 billing_city,SUM(total) as invoice_totals
from invoice
group by  billing_city
order by invoice_totals desc;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/


select * from customer;
select * from invoice;

select c.customer_id,c.first_name,c.last_name,sum(i.total) as spent_money
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id
order by spent_money desc;


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


select * from customer;
select * from invoice;
select * from invoice_line;
select * from track;
select * from genre;

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice
ON invoice.customer_id = customer.customer_id
JOIN invoice_line
ON invoice_line.invoice_id = invoice.invoice_id
JOIN track 
ON track.track_id = invoice_line.track_id
JOIN genre
ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select * from artist
select * from track
select * from genre


select a.artist_id,a.name,count(a.artist_id)as number_of_songs
from track as t
join album as al
on al.album_id=t.album_id
join artist as a
on a.artist_id=al.album_id
join genre as g
on g.genre_id=t.genre_id
where g.name like 'Rock'
group by a. artist_id
order by number_of_songs desc;






/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds
from track
where milliseconds>(
    select AVG(milliseconds) as avg_song_length
	from track)
	order by milliseconds desc;




	/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */



select * from customer
select * from invoice
select * from invoice_line
select * from track
select * from artist
select * from album;


WITH best_selling_artist AS (
	SELECT  top 1 artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id
	ORDER BY  total_sales DESC
	
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent  DESC;

/*
 Q-10-We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.*/

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY  customer.country, genre.name, genre.genre_id
	--ORDER BY  customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



/*row number ki help se saari category/group me se  singal highest find krnma hai to row no ,partition ki help se krte hain*/

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country)
		--ORDER BY billing_country ASC,total_spending DESC
 SELECT * FROM Customter_with_country WHERE RowNo <= 1
