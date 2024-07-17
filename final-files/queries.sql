-- Q1 - WHICH EMPLOYEE HAS SOLD THE MOST?
/*
In general, Stephens Jon tends to contribute significantly more to sales compared to the rest of the staff. Notably, in the month of May, the gap in his favor is greater compared to other months.
*/

WITH p1 AS (
    SELECT 
        DATE_TRUNC('month', p.payment_date) + INTERVAL '1 month' - INTERVAL '1 second' AS payment_date_eom,
        p.staff_id,
        p.amount
    FROM payment p
),
p2 AS (
    SELECT 
        payment_date_eom,
        SUM(p1.amount) AS amt_tot_month
    FROM p1
    GROUP BY payment_date_eom
)
SELECT 
    p1.payment_date_eom,
    CONCAT(s.last_name, ' ', s.first_name) AS employee_name,
    SUM(amount) AS amt_staff,
    MAX(p2.amt_tot_month) AS amt_tot_month,
    SUM(amount) / MAX(p2.amt_tot_month) * 100 AS perc_profit_per_staff
FROM staff s
JOIN p1 ON s.staff_id = p1.staff_id 
JOIN p2 ON p1.payment_date_eom = p2.payment_date_eom
GROUP BY p1.payment_date_eom, s.staff_id, CONCAT(s.last_name, ' ', s.first_name)
ORDER BY p1.payment_date_eom, CONCAT(s.last_name, ' ', s.first_name);

-- Q2 - IS IT POSSIBLE TO OPTIMIZE THE FILM INVENTORY?
/*
4.2% of the films do not have excess copies but have not had any rentals and are not in the inventory. I suggest updating the film list to remove them.

76.10% of the films have one more copy than the historical maximum of concurrent rentals. This is considered the standard and ensures an additional copy in case of unusual demand.

The remaining 19.70% of the films have 2 or more copies in excess compared to the historical maximum of concurrent rentals. Here, it might be possible to optimize by selling the excess copies, thus reducing storage costs or potential waste in future purchases of unnecessary copies.
*/

WITH 
-- Rentals with film info
t0 AS (
    SELECT 
        r1.rental_id,
        r1.rental_date,
        r1.return_date,
        r1.inventory_id,
        i.film_id
    FROM rental r1
    JOIN inventory i ON r1.inventory_id = i.inventory_id 
),
-- Rentals with data on parallel rentals
t2 AS (
    SELECT 
        t0.rental_id,
        t0.film_id,
        COUNT(DISTINCT t1.inventory_id) AS parallel_rental
    FROM t0
    LEFT JOIN t0 t1 ON t0.rental_id <> t1.rental_id
    AND t0.film_id = t1.film_id
    AND t1.rental_date BETWEEN t0.rental_date AND t0.return_date
    GROUP BY t0.rental_id, t0.film_id
    ORDER BY t0.rental_id
),
-- Maximum parallel rentals per film
t3 AS (
    SELECT 
        film_id,
        MAX(parallel_rental) AS max_parallel_rental
    FROM t2
    GROUP BY film_id
),
-- Copies in stock per film
t4 AS (
    SELECT 
        f.film_id,
        COUNT(i.inventory_id) AS copies_in_stock
    FROM film f
    LEFT JOIN inventory i ON f.film_id = i.film_id
    GROUP BY f.film_id
),
t5 AS (
    -- Base data with metrics of interest
    SELECT 
        t3.film_id,
        t3.max_parallel_rental,
        t4.copies_in_stock,
        t4.copies_in_stock - t3.max_parallel_rental AS excess_copies
    FROM t3
    LEFT JOIN t4 ON t3.film_id = t4.film_id
),
t6 AS (
    -- Detail per film with complete metrics
    SELECT 
        f.film_id,
        f.title,
        COALESCE(t5.max_parallel_rental, 0) AS max_parallel_rental,
        COALESCE(t5.copies_in_stock, 0) AS copies_in_stock,
        COALESCE(t5.excess_copies, 0) AS excess_copies
    FROM film f
    LEFT JOIN t5 ON f.film_id = t5.film_id
    ORDER BY COALESCE(t5.excess_copies, 0) DESC
)
SELECT 
    excess_copies,
    MAX((SELECT COUNT(*) FROM film)) AS total_films,
    COUNT(*) AS film_count_per_category,
    COUNT(*)::DECIMAL / MAX((SELECT COUNT(*) FROM film)) AS perc_films_per_category
FROM t6
GROUP BY excess_copies;

-- Q3 - HOW IS THE DAILY PAYMENT TREND COMPARED TO THE PREVIOUS DAY DIVIDED BY MOVIE RATING?
/*
Analyzing the graph, it is possible to notice a very inconsistent trend. It is evident from the graph that within the sample
there is a possible pattern characterized by a significant drop in sales of about 90% regardless of the movie rating, followed by
considerable sales peaks reaching increases in the order of 700% compared to the previous day.
*/

WITH t0 AS (
    SELECT 
        DATE_TRUNC('day', p.payment_date) AS ref_date,
        f.rating,
        p.amount
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
),
t1 AS (
    SELECT 
        ref_date,
        rating,
        SUM(amount) AS amt_sum
    FROM t0
    GROUP BY ref_date, rating
),
t2 AS (
    SELECT 
        ref_date,
        rating,
        amt_sum,
        LAG(amt_sum) OVER (PARTITION BY rating ORDER BY ref_date) AS prev_amt_sum
    FROM t1
),
t3 AS (
    SELECT 
        ref_date,
        rating,
        amt_sum,
        amt_sum - COALESCE(prev_amt_sum, 0) AS diff_cumulative,
        CASE 
            WHEN prev_amt_sum IS NULL THEN 0
            ELSE (amt_sum - COALESCE(prev_amt_sum, 0)) / COALESCE(prev_amt_sum, 0)
        END AS perc_change
    FROM t2
    WHERE 
        CASE 
            WHEN prev_amt_sum IS NULL THEN 0
            ELSE (amt_sum - COALESCE(prev_amt_sum, 0)) / COALESCE(prev_amt_sum, 0)
        END <> 0
)
SELECT 
    ref_date,
    rating,
    amt_sum,
    diff_cumulative,
    perc_change
FROM 
    t3
ORDER BY 
    ref_date, rating;


-- Q4 - IN QUALE CITTà O PAESE CONVERREBBE APRIRE UN NUOVO PUNTO VENDITA?(HEETMAP SU MAPPA)

