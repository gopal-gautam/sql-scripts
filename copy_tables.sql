CREATE TEMPORARY TABLE tmptable_1 SELECT * FROM `participated_in` where event_id = 578;
UPDATE tmptable_1 SET event_id = 483, participated_in_id=NULL;
INSERT INTO `participated_in` SELECT * FROM tmptable_1;
DROP TEMPORARY TABLE IF EXISTS tmptable_1;
