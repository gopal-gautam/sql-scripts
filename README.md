# sql-scripts

* ## Copy-tables
- Copy content of one table to another. Here a particular from participated_in table is duplicated modifying a column value.
```sql
CREATE TEMPORARY TABLE tmptable_1 SELECT * FROM `participated_in` where event_id = 578;
UPDATE tmptable_1 SET event_id = 483, participated_in_id=NULL;
INSERT INTO `participated_in` SELECT * FROM tmptable_1;
DROP TEMPORARY TABLE IF EXISTS tmptable_1;
```
