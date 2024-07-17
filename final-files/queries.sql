-- Q1 STORICO IMPIEGATO DEL MESE PER NUMERO DI profitti FATTI
with p1 as (
select 
date_trunc('month', p.payment_date)+ interval '1 month' - interval '1 second' as payment_date_eom,
p.staff_id,
p.amount
from payment p
)
select 
p1.payment_date_eom,
concat(s.last_name,' ',s.first_name) as nominativo,
sum(amount) as amt_staff
from staff s
join p1 on s.staff_id = p1.staff_id 
group by p1.payment_date_eom,
s.staff_id,
concat(s.last_name,' ',s.first_name)
order by p1.payment_date_eom,
concat(s.last_name,' ',s.first_name)

-- QUALE CATEGORIA è LA PIù REDDITIZIA PER LE FASCE DI ETA'

-- QUAL'è IL RAPPORTO NUMERO DI DIPENDENTI/NUMERO DEI CLIENTI PER OGNI STORE

-- QUAL'è L'ENTRATA MEDIA DI OGNI CITTà (HEETMAP SU MAPPA)