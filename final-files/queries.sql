-- Q1 - QUAL'E' L'IMPIEGATO CHE HA VENDUTO DI PIU'?
with p1 as (
select 
date_trunc('month', p.payment_date)+ interval '1 month' - interval '1 second' as payment_date_eom,
p.staff_id,
p.amount
from payment p
)
,P2 AS (
SELECT PAYMENT_DATE_EOM
 ,SUM(P1.AMOUNT) AS AMT_TOT_MONTH
FROM P1
GROUP BY PAYMENT_DATE_EOM )
select 
p1.payment_date_eom,
concat(s.last_name,' ',s.first_name) as nominativo,
SUM(AMOUNT) AS AMT_STAFF,
MAX(P2.AMT_TOT_MONTH) AS AMT_TOT_MONTH,
SUM(AMOUNT)/MAX(P2.AMT_TOT_MONTH)*100 AS PERC_PROFIT_PER_STAFF
from staff s
join p1 on s.staff_id = p1.staff_id 
JOIN P2 ON P1.PAYMENT_DATE_EOM=P2.PAYMENT_DATE_EOM
group by p1.payment_date_eom,
s.staff_id,
concat(s.last_name,' ',s.first_name)
order by p1.payment_date_eom,
concat(s.last_name,' ',s.first_name)

-- Q2 - E' POSSIBILE OTTIMIZZARE L'INVENTARIO DEI FILM?
/*
il 4,2% dei film non ha copie in sovrannumero ma ho scoperto
che non hanno avuto nessun rental e non sono presenti nell'inventario, suggerisco un
aggiornamento della lista film per eliminarli.

il 76,10% dei film ha una copia in più rispetto al massimo storico di copie noleggiare contemporaneamente. Questo
dato lo ritengo lo standard e da certezza di possedere una copia in più in caso di affluenza anomala.

il restante 19,70% dei film presenta 2 o più copie in più rispetto al massimo storico di copie noleggiare contemporaneamente.
Qui credo sia possibile fare un'ottimizzazione vendendo le copie effettuare e riducendo così costi di magazzinaggio o eventuali sprechi nell'
acquisto di copie superflue in futuro.
*/

with 
-- rental con info sul film
t0 as (
select 
r1.rental_id,
r1.rental_date,
r1.return_date,
r1.inventory_id,
i.film_id
from rental r1
join inventory i on r1.inventory_id = i.inventory_id 
)
-- rental con dato sui rental paralleli
,t2 as (
select 
t0.rental_id,
t0.film_id,
count(distinct t1.inventory_id) as parallel_rental
from t0
left join t0 t1 on t0.rental_id <> t1.rental_id
and t0.film_id = t1.film_id
and t1.rental_date between t0.rental_date and t0.return_date
group by t0.rental_id,
t0.film_id
order by t0.rental_id
)
-- massimo di rental paralleli per film
,t3 as (
select 
film_id,
max(parallel_rental) as max_parallel_rental
from t2
group by film_id
)
,t4 as (
-- copie in magazzino per ogni film
select 
f.film_id,
count(i.inventory_id) as copie_in_magazzino
from film f
left join inventory i on f.film_id = i.film_id
group by f.film_id
)
, t5 as (
-- dato di base con metriche di interesse
select 
t3.film_id,
t3.max_parallel_rental,
t4.copie_in_magazzino,
t4.copie_in_magazzino-t3.max_parallel_rental as copie_in_sovrannumero
from t3
left join t4 on t3.film_id = t4.film_id
)
, t6 as (
-- dettaglio per singolo film con metriche complete
select 
f.film_id,
f.title,
coalesce(t5.max_parallel_rental,0) as max_parallel_rental,
coalesce(t5.copie_in_magazzino,0) as copie_in_magazzino,
coalesce(t5.copie_in_sovrannumero,0) as copie_in_sovrannumero
from film f
left join t5 on f.film_id = t5.film_id
order by coalesce(t5.copie_in_sovrannumero,0) desc
)
select 
copie_in_sovrannumero,
max((select count(*) from film)) as totale_film,
count(*) as cnt_film_per_categoria,
count(*)::decimal/max((select count(*) from film)) as perc_film_per_cat
from t6
group by copie_in_sovrannumero
;

-- Q3 - IN QUALE GIORNO DELLA SETTIMANA CONVERREBBE PROPORRE STRAORDINARI AI DIPENDENTI SULLA BASE DEI VOLUMI DI AFFLUENZA?

-- Q4 - IN QUALE CITTà O PAESE CONVERREBBE APRIRE UN NUOVO PUNTO VENDITA?(HEETMAP SU MAPPA)

