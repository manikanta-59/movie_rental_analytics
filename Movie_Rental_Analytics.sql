SELECT 
    customer_type,
    COUNT(*) AS number_of_customers,
    AVG(total_rentals) AS avg_rentals,
    AVG(total_spent) AS avg_spending,
    SUM(total_spent) AS total_revenue
FROM (
    SELECT 
        r.customer_id,
        COUNT(r.rental_id) AS total_rentals,
        SUM(p.amount) AS total_spent,
        CASE 
            WHEN COUNT(r.rental_id) = 1 THEN 'New Customer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM rental r
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY r.customer_id
) AS customer_summary
GROUP BY customer_type;


-- Q2 
SELECT 
    f.title,
    f.rental_rate,
    COUNT(r.rental_id) AS total_rentals
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title, f.rental_rate
ORDER BY total_rentals DESC
LIMIT 10;
-- Q3
SELECT 
    s.staff_id,
    COUNT(r.rental_id) AS total_rentals,
    SUM(p.amount) AS total_revenue,
    COUNT(DISTINCT r.customer_id) AS unique_customers
FROM staff s
JOIN rental r ON s.staff_id = r.staff_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY s.staff_id;

-- Q4
SELECT 
    MONTH(r.rental_date) AS month,
    ci.city,
    COUNT(r.rental_id) AS total_rentals
FROM rental r
JOIN customer cu ON r.customer_id = cu.customer_id
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
GROUP BY month, ci.city
ORDER BY month, total_rentals DESC;

-- Q5
SELECT 
    customer_segment,
    l.name AS language,
    COUNT(r.rental_id) AS total_rentals
FROM (
    SELECT 
        customer_id,
        CASE 
            WHEN COUNT(rental_id) >= 30 THEN 'High Activity'
            WHEN COUNT(rental_id) BETWEEN 15 AND 29 THEN 'Medium Activity'
            ELSE 'Low Activity'
        END AS customer_segment
    FROM rental
    GROUP BY customer_id
) AS customer_seg
JOIN rental r ON customer_seg.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN language l ON f.language_id = l.language_id
GROUP BY customer_segment, l.name
ORDER BY customer_segment, total_rentals DESC;

-- Q6
SELECT 
    MONTH(r.rental_date) AS month,
    CASE 
        WHEN cust_rentals.total_rentals = 1 THEN 'New Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    SUM(p.amount) AS total_revenue
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN (
    SELECT 
        customer_id,
        COUNT(rental_id) AS total_rentals
    FROM rental
    GROUP BY customer_id
) AS cust_rentals 
ON r.customer_id = cust_rentals.customer_id
GROUP BY month, customer_type
ORDER BY month desc;

-- Q7
SELECT *
FROM (
    SELECT 
        co.country,
        c.name AS category,
        COUNT(r.rental_id) AS total_rentals,
        RANK() OVER (PARTITION BY co.country ORDER BY COUNT(r.rental_id) DESC) AS rank_num
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    JOIN customer cu ON r.customer_id = cu.customer_id
    JOIN address a ON cu.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    GROUP BY co.country, c.name
) AS ranked_data
WHERE rank_num <= 5;

-- Q8
SELECT 
    s.staff_id,
    COUNT(r.rental_id) AS total_rentals,
    SUM(p.amount) AS total_revenue,
    COUNT(DISTINCT r.customer_id) AS unique_customers
FROM staff s
JOIN rental r ON s.staff_id = r.staff_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY s.staff_id;

-- Q9
SELECT 
    s.store_id,
    co.country,
    COUNT(r.rental_id) AS total_rentals,
    COUNT(DISTINCT r.customer_id) AS total_customers,
    ROUND(COUNT(r.rental_id) / COUNT(DISTINCT r.customer_id), 2) AS rentals_per_customer
FROM rental r
JOIN customer cu ON r.customer_id = cu.customer_id
JOIN store s ON cu.store_id = s.store_id
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY s.store_id, co.country
ORDER BY rentals_per_customer DESC;

-- Q10
SELECT 
    customer_segment,
    c.name AS category,
    COUNT(r.rental_id) AS total_rentals
FROM (
    SELECT 
        customer_id,
        CASE 
            WHEN COUNT(rental_id) >= 30 THEN 'High Activity'
            WHEN COUNT(rental_id) BETWEEN 15 AND 29 THEN 'Medium Activity'
            ELSE 'Low Activity'
        END AS customer_segment
    FROM rental
    GROUP BY customer_id
) AS customer_seg
JOIN rental r ON customer_seg.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY customer_segment, c.name
ORDER BY customer_segment, total_rentals DESC;

-- Q11
SELECT 
    co.country,
    ci.city,
    c.name AS category,
    COUNT(r.rental_id) AS total_rentals
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
JOIN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 10
) AS top_customers ON r.customer_id = top_customers.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN customer cu ON r.customer_id = cu.customer_id
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY co.country, ci.city, c.name
ORDER BY total_rentals DESC;

-- Q12
SELECT 
    f.title,
    COUNT(i.inventory_id) AS total_inventory,
    COUNT(r.rental_id) AS total_rentals,
    COUNT(DISTINCT r.customer_id) AS repeat_customers,
    ROUND(COUNT(r.rental_id) / COUNT(i.inventory_id), 2) AS rentals_per_inventory
FROM film f
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY total_rentals DESC
LIMIT 10;

-- Q13
SELECT 
    s.store_id,
    DAYNAME(r.rental_date) AS day,
    HOUR(r.rental_date) AS hour,
    COUNT(r.rental_id) AS total_rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN store s ON i.store_id = s.store_id
GROUP BY s.store_id, day, hour
ORDER BY s.store_id, total_rentals DESC;

-- Q14
SELECT *
FROM (
    SELECT 
        co.country,
        c.name AS category,
        COUNT(r.rental_id) AS total_rentals,
        RANK() OVER (PARTITION BY co.country ORDER BY COUNT(r.rental_id) DESC) AS rank_num
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    JOIN customer cu ON r.customer_id = cu.customer_id
    JOIN address a ON cu.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    GROUP BY co.country, c.name
) ranked
WHERE rank_num <= 5;

-- Q15
SELECT 
    l.name AS language,
    COUNT(DISTINCT f.film_id) AS total_films,
    COUNT(r.rental_id) AS total_rentals,
    COUNT(DISTINCT r.customer_id) AS customers,
    ROUND(COUNT(r.rental_id) / COUNT(DISTINCT r.customer_id), 2) AS rentals_per_customer
FROM language l
LEFT JOIN film f ON l.language_id = f.language_id
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY l.name;