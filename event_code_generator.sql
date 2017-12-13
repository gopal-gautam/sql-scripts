DELIMITER $$
DROP PROCEDURE IF EXISTS yearly_munwise_event_counts $$
CREATE PROCEDURE yearly_munwise_event_counts
(
	IN event_subcat_id int(11)
)
BEGIN
	select e.coverage_location as program_location, e.year as program_year, count(e.event_id) as total_events, 
	( 	
		select count(*) from participated_in as pin 
		join events as e on pin.event_id = e.event_id	
		where e.year = program_year and e.coverage_location = program_location and e.course_subcat_id=event_subcat_id and pin.is_instructor=0	
	) as total_pariticipants	
	from events as e	
	where e.course_subcat_id = event_subcat_id	
	group by e.year, e.coverage_location;	

END $$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS gen_event_code $$
CREATE PROCEDURE gen_event_code
(
	IN event_subcat_id int(11),
	IN coverage_location varchar(100),
	IN end_date date,
	IN project varchar(20),
	OUT e_code VARCHAR(100)
)
BEGIN
	DECLARE num_cov int;
    DECLARE num_all int;
	SELECT 
	(
		SELECT COUNT(e.event_id) FROM EVENTS as e WHERE
			e.project = project AND
			e.course_subcat_id = event_subcat_id AND
			e.coverage_location = coverage_location AND
			e.end_date < end_date
	),
	(
		SELECT COUNT(e.event_id) FROM EVENTS as e WHERE
			e.project = project AND
			e.course_subcat_id = event_subcat_id AND
			e.end_date < end_date
	) INTO num_cov, num_all;
	SELECT CONCAT(event_subcat_id, "-", coverage_location, "-", num_cov, "-", num_all) INTO e_code;
END $$
DELIMITER ;

call gen_event_code(3, "Bharatpur", "2017-01-01");

DELIMITER $$
DROP PROCEDURE IF exists update_events_with_event_code $$
CREATE PROCEDURE update_events_with_event_code()
BEGIN
	DECLARE done INT DEFAULT 0;
	DECLARE ev int(11);
    DECLARE cid int(11);
    DECLARE cv varchar(100);
    DECLARE ed date;       
    DECLARE curl CURSOR FOR SELECT event_id, course_subcat_id, coverage_location, end_date FROM events;
    OPEN curl;
    read_loop: LOOP
		IF done THEN
			LEAVE read_loop;
		END IF;
        FETCH curl INTO ev, cid, cv, ed;
        SET @e_code = ''; 
		CALL gen_event_code(cid,cv,ed,@e_code);
		UPDATE events SET event_code=@e_code WHERE event_id=ev;
	END LOOP;
    CLOSE curl;
    
END $$
DELIMITER ;

CALL update_events_with_event_code();


-- CREATE TEMPORARY TABLE tmpl_tbl SELECT event_id, course_subcat_id, coverage_location, end_date FROM events;
-- SELECT event_id, course_subcat_id, coverage_location, end_date into ev,cid,cv FROM events;
-- SET @event_code = '';
-- CALL gen_event_code(ev,cid,cv,@event_code);
-- UPDATE events SET event_code=@event_code WHERE event_id=event_id
-- DROP TEMPORARY TABLE IF EXISTS tmpl_tbl;


-- DELIMITER $$
-- CREATE PROCEDURE test ()
-- BEGIN
-- DECLARE done INT DEFAULT 0;
-- DECLARE eid INT;
-- DECLARE loc VARCHAR(100);
-- DECLARE edt DATE;
-- DECLARE cur1 CURSOR FOR SELECT event_id, coverage_location, end_date FROM events;
-- DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
-- OPEN cur1;
-- read_loop: LOOP
	-- IF done THEN
		-- LEAVE read_loop;
	-- END IF;
	-- FETCH cur1 INTO eid, loc, edt;
	-- CALL gen_event_code(eid, loc, edt);
-- END LOOP;

-- CLOSE cur1;
-- END $$
-- DELIMITER ;

DELIMITER $$
DROP TRIGGER IF EXISTS after_event_insert $$
CREATE TRIGGER after_event_insert 
AFTER INSERT ON events
FOR EACH ROW
BEGIN
SET @e_code='';
CALL gen_event_code(new.course_subcat_id, new.coverage_location, new.end_date, @e_code);
UPDATE events SET event_code=@e_code WHERE event_id=new.event_id;
END $$
DELIMITER ;


DELIMITER $$
DROP PROCEDURE IF EXISTS update_event_with_event_code $$
CREATE PROCEDURE update_event_with_event_code (
	IN eid INT(11)
)
BEGIN
	DECLARE cid INT(11);
	DECLARE cv VARCHAR(100);
	DECLARE ed date;
	DECLARE prj VARCHAR(20);
	SET @e_code = '';
	
	SELECT events.course_subcat_id, events.coverage_location, events.end_date, events.project INTO cid,cv,ed,prj FROM events WHERE events.event_id=eid;
	CALL gen_event_code(cid, cv, ed, prj, @e_code);
	UPDATE events SET events.event_code=@e_code WHERE events.event_id=eid;
END $$
DELIMITER ;



		
