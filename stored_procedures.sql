'munwise_yearly_no_of_events. '
DELIMITER $$
CREATE PROCEDURE munwise_yearly_no_of_events(
	IN subcat_id
)
BEGIN
	select e.coverage_location as ProgramLoc, e.year as ProgramYear, e.course_subcat_id as MT, 
	(
		select sum(ecs.share) from event_cost_shares as ecs join events as ev where ev.coverage_location=ProgramLoc and ecs.party_id=5
	) as NSET_Share
	from events as e
	where e.course_subcat_id = subcat_id	
	group by e.year, e.coverage_location
END $$
DELIMITER ;

