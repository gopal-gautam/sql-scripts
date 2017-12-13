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
## Fulltext search of events on codeigniter
```php
$query = sprintf('SELECT * FROM events WHERE (events.title LIKE %1\$s OR events.event_code LIKE %1\$s OR events.coverage_location LIKE %1\$s OR events.address LIKE %1\$s OR events.venue LIKE %1\$s) AND deleted=0  ORDER BY start_date DESC LIMIT %2\$s, %3\$s', self::escape($search_string), $start, $end);
```
