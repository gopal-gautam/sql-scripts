# sql-scripts

## Copy-tables
- Copy content of one table to another. Here a particular from participated_in table is duplicated modifying a column value.
```sql
CREATE TEMPORARY TABLE tmptable_1 SELECT * FROM `participated_in` where event_id = 578;
UPDATE tmptable_1 SET event_id = 483, participated_in_id=NULL;
INSERT INTO `participated_in` SELECT * FROM tmptable_1;
DROP TEMPORARY TABLE IF EXISTS tmptable_1;
```
## Error with year, start_date or end_date
```sql
SELECT concat("http://192.168.100.18/bcipn/event/viewEvent?id=",event_id) as link, coverage_location, start_date, end_date, year FROM `events` where year(start_date)!= year and year(end_date)!= year
```
## Number of days between start_date and end_date is greater than 7
```sql
SELECT concat("http://192.168.100.18/bcipn/event/viewEvent?id=",event_id) as link, coverage_location, start_date, end_date, subcoursename, datediff(end_date,start_date) as days FROM `events` left join course_subcategory on events.course_subcat_id=course_subcategory.course_subcat_id where datediff(end_date,start_date) > 7
```
## Invalid Coverage Location
```sql
SELECT * FROM `events` where coverage_location not in (select coverage_location from coverage_location)
```
## Persons with same mobile
```sql
SELECT group_concat(concat("http://192.168.100.18/bcipn/person/viewPerson?id=",person_id)) as links, count(*) ct, group_concat(fullname) as names, mobile FROM `person` group by mobile having ct>1 and mobile <> ''
```
## Persons with gender mismatch
```sql
SELECT * FROM `person` where (title="Mr." and gender="Female") or (title="Ms." and gender="Male")
```
## Number of days between start_date and end_date is greater than 7 from baliyoghar
```sql
SELECT concat("http://192.168.100.18/baliyoghar/Event/viewEvent?id=",event_id) as link, district, vdc, ward_no, start_date, end_date, subcoursename as event_type, events.created_by as user, events.event_code as event_code, datediff(end_date,start_date) as  no_of_days FROM `events` left join course_subcategory on events.course_subcat_id=course_subcategory.course_subcat_id where events.created_by != 'admin' and ((start_date > end_date) or (datediff(end_date, start_date)) > 7)
```
## Finding not matched with total participants and no of pax
```sql
select * from
(
select concat("http://localhost/bcipn/event/viewEvent?id=",ev.event_id) as link, 
ev.title, ev.coverage_location, ev.year, ev.start_date, ev.end_date,
count(p.person_id) as total_participant,
(
    select sum(ink.pax) from inkind_contribution as ink where ink.event_id = ev.event_id
) as pax
from events as ev 
join participated_in as pin on pin.event_id = ev.event_id 
join person as p on p.person_id = pin.person_id
where pin.is_instructor = 0
group by ev.event_id
) q
where total_participant != pax
```

## Reports 1
```sql
SELECT ecs.event_id, cs.course_subcat_id, ecs.party_id, ecs.share, dc.tdc, dc.staff_cost, dc.travel_cost FROM event_cost_shares AS ecs JOIN direct_cost AS dc ON ecs.event_id = dc.event_id JOIN events AS e ON e.event_id = dc.event_id JOIN course_subcategory AS cs ON cs.course_subcat_id = e.course_subcat_id
```

## Reports 2
```sql
select e.coverage_location as ProgramLoc, e.year as ProgramYear, e.course_subcat_id as MT, 
(
	select sum(ecs.share) from event_cost_shares as ecs join events as ev where ev.coverage_location=ProgramLoc and ecs.party_id=5
) as NSET_Share
from events as e
where e.course_subcat_id = 3	
group by e.year, e.coverage_location	

SELECT e.coverage_location AS ProgramLoc, e.year AS ProgramYear, (

SELECT SUM( ecs.share ) 
FROM event_cost_shares AS ecs
JOIN events AS ev ON ecs.event_id = ev.event_id
WHERE ev.coverage_location = ProgramLoc
AND ecs.party_id =5
AND ev.course_subcat_id =3
AND ev.year = ProgramYear
) AS NSET_Share, (

SELECT SUM( ecs.share ) 
FROM event_cost_shares AS ecs
JOIN events AS ev ON ecs.event_id = ev.event_id
WHERE ev.coverage_location = ProgramLoc
AND ecs.party_id =6
AND ev.course_subcat_id =3
AND ev.year = ProgramYear
) AS Munic_Share, (

SELECT SUM( ecs.share ) 
FROM event_cost_shares AS ecs
JOIN events AS ev ON ecs.event_id = ev.event_id
WHERE ev.coverage_location = ProgramLoc
AND ecs.party_id =7
AND ev.course_subcat_id =3
AND ev.year = ProgramYear
) AS Other_Share

FROM events AS e
WHERE e.course_subcat_id =3
GROUP BY e.year, e.coverage_location
```

## Fulltext search of events on codeigniter
```php
$query = sprintf('SELECT * FROM events WHERE (events.title LIKE %1\$s OR events.event_code LIKE %1\$s OR events.coverage_location LIKE %1\$s OR events.address LIKE %1\$s OR events.venue LIKE %1\$s) AND deleted=0  ORDER BY start_date DESC LIMIT %2\$s, %3\$s', self::escape($search_string), $start, $end);
```
