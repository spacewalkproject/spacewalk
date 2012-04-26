
update rhn_schedule_days
set start_1 = to_timestamp('2000-09-08 12:00:02 AM','YYYY-MM-DD HH:MI:SS AM')
where schedule_id = ( select recid from rhn_schedules where customer_id is null and description = '24x7' )
and ord = 0
	and end_1 = to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM')
	and start_2 is null and end_2 is null
	and start_3 is null and end_3 is null
	and start_4 is null and end_4 is null;

update rhn_schedule_days
set start_1 = to_timestamp('2000-09-08 12:00:09 AM','YYYY-MM-DD HH:MI:SS AM')
where schedule_id = ( select recid from rhn_schedules where customer_id is null and description = '24x7' )
and ord = 1
	and end_1 = to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM')
	and start_2 is null and end_2 is null
	and start_3 is null and end_3 is null
	and start_4 is null and end_4 is null;

update rhn_schedule_days
set start_1 = to_timestamp('2000-09-08 12:00:14 AM','YYYY-MM-DD HH:MI:SS AM')
where schedule_id = ( select recid from rhn_schedules where customer_id is null and description = '24x7' )
and ord = 2
	and end_1 = to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM')
	and start_2 is null and end_2 is null
	and start_3 is null and end_3 is null
	and start_4 is null and end_4 is null;

update rhn_schedule_days
set start_1 = to_timestamp('2000-09-08 12:00:20 AM','YYYY-MM-DD HH:MI:SS AM')
where schedule_id = ( select recid from rhn_schedules where customer_id is null and description = '24x7' )
and ord = 3
	and end_1 = to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM')
	and start_2 is null and end_2 is null
	and start_3 is null and end_3 is null
	and start_4 is null and end_4 is null;

update rhn_schedule_days
set start_1 = to_timestamp('2000-09-08 12:00:25 AM','YYYY-MM-DD HH:MI:SS AM')
where schedule_id = ( select recid from rhn_schedules where customer_id is null and description = '24x7' )
and ord = 4
	and end_1 = to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM')
	and start_2 is null and end_2 is null
	and start_3 is null and end_3 is null
	and start_4 is null and end_4 is null;

update rhn_schedule_days
set start_1 = to_timestamp('2000-09-08 12:00:31 AM','YYYY-MM-DD HH:MI:SS AM')
where schedule_id = ( select recid from rhn_schedules where customer_id is null and description = '24x7' )
and ord = 5
	and end_1 = to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM')
	and start_2 is null and end_2 is null
	and start_3 is null and end_3 is null
	and start_4 is null and end_4 is null;

update rhn_schedule_days
set start_1 = to_timestamp('2000-09-08 12:00:36 AM','YYYY-MM-DD HH:MI:SS AM')
where schedule_id = ( select recid from rhn_schedules where customer_id is null and description = '24x7' )
and ord = 6
	and end_1 = to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM')
	and start_2 is null and end_2 is null
	and start_3 is null and end_3 is null
	and start_4 is null and end_4 is null;

commit;

