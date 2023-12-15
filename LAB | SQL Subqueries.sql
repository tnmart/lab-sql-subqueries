-- Write SQL queries to perform the following tasks using the Sakila database:
USE sakila;
-- 1.Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

SELECT COUNT(inventory_id) AS number_of_copies
FROM inventory AS i
JOIN film AS f
ON i.film_id = f.film_id
WHERE title = "HUNCHBACK IMPOSSIBLE";

-- 2.List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT AVG(length) FROM film;

SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- 3.Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT a.first_name, a.last_name, f.title
FROM actor AS a
JOIN film_actor AS fa
ON a.actor_id=fa.actor_id
JOIN film AS f
ON fa.film_id=f.film_id
WHERE f.title = "ALONE TRIP";

-- 4.Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized
-- as family films.

SELECT title
FROM film AS f
JOIN film_category AS fc
ON f.film_id = fc.film_id
JOIN category AS c
ON fc.category_id = c.category_id
WHERE c.name = "Family";

-- 5.Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the
-- relevant tables and their primary and foreign keys.

-- Using joins
SELECT
	c.first_name,
    c.last_name,
    c.email
FROM customer AS c
LEFT JOIN address AS a
ON c.address_id = a.address_id
JOIN city AS ci
ON a.city_id = ci.city_id
JOIN country as co
ON ci.country_id = co.country_id
WHERE country = "Canada";

SELECT
	first_name,
    last_name,
    email
    FROM customer
    WHERE address_id IN
		(SELECT address_id
		FROM address
		WHERE city_id IN
			(SELECT city_id
			FROM city
			WHERE country_id IN
				(SELECT country_id
				FROM country
				WHERE country = "Canada")));

-- 6. Determine which films were starred by the most prolific actor in the Sakila database.
-- A prolific actor is defined as the actor who has acted in the most number of films.
-- First, you will need to find the most prolific actor and then use that actor_id to find the
-- different films that he or she starred in.

SELECT title
FROM film
WHERE film_id IN
	(SELECT film_id
	FROM film_actor
	WHERE actor_id IN
		(SELECT actor_id
		FROM
			(SELECT
				actor_id,
				COUNT(actor_id) AS number_of_films
			FROM film_actor
			GROUP BY actor_id
			ORDER BY number_of_films DESC
			LIMIT 1
			) AS prolific_actor));

-- 7.Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the
-- most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT title
FROM film
WHERE film_id IN
(SELECT film_id
FROM inventory
WHERE inventory_id IN
	(SELECT inventory_id
	FROM rental
	WHERE customer_id =
		(SELECT customer_id
		FROM
			(SELECT
				customer_id,
				SUM(amount) AS total_amount
			FROM payment
			GROUP BY customer_id
			ORDER BY total_amount DESC
			LIMIT 1) AS most_profitable_customer)));
        
-- 8.Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent
-- by each client. You can use subqueries to accomplish this.
SELECT
	customer_id,
    SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
    HAVING total_amount_spent > 
		(SELECT AVG(total_amount)
		FROM
		(SELECT
			r.customer_id,
			SUM(AMOUNT) AS total_amount
		FROM payment AS p
		JOIN rental AS r
		ON p.rental_id = r.rental_id
		GROUP BY r.customer_id) AS average_amount);

