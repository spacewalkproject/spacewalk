--
-- Copyright (c) 2010--2012 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--

--data for rhn_schedule_days
--only include the 24 x 7 schedule

insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( sequence_nextval('rhn_schedule_days_recid_seq'),
      ( select recid from rhn_schedules where customer_id is null and description = '24x7' ),0,
    to_timestamp('2000-09-08 12:00:02 AM','YYYY-MM-DD HH:MI:SS AM'),
    to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( sequence_nextval('rhn_schedule_days_recid_seq'),
      ( select recid from rhn_schedules where customer_id is null and description = '24x7' ),1,
    to_timestamp('2000-09-08 12:00:09 AM','YYYY-MM-DD HH:MI:SS AM'),
    to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( sequence_nextval('rhn_schedule_days_recid_seq'),
      ( select recid from rhn_schedules where customer_id is null and description = '24x7' ),2,
    to_timestamp('2000-09-08 12:00:14 AM','YYYY-MM-DD HH:MI:SS AM'),
    to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( sequence_nextval('rhn_schedule_days_recid_seq'),
      ( select recid from rhn_schedules where customer_id is null and description = '24x7' ),3,
    to_timestamp('2000-09-08 12:00:20 AM','YYYY-MM-DD HH:MI:SS AM'),
    to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( sequence_nextval('rhn_schedule_days_recid_seq'),
      ( select recid from rhn_schedules where customer_id is null and description = '24x7' ),4,
    to_timestamp('2000-09-08 12:00:25 AM','YYYY-MM-DD HH:MI:SS AM'),
    to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( sequence_nextval('rhn_schedule_days_recid_seq'),
      ( select recid from rhn_schedules where customer_id is null and description = '24x7' ),5,
    to_timestamp('2000-09-08 12:00:31 AM','YYYY-MM-DD HH:MI:SS AM'),
    to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( sequence_nextval('rhn_schedule_days_recid_seq'),
      ( select recid from rhn_schedules where customer_id is null and description = '24x7' ),6,
    to_timestamp('2000-09-08 12:00:36 AM','YYYY-MM-DD HH:MI:SS AM'),
    to_timestamp('2000-09-09 12:00:00 AM','YYYY-MM-DD HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
commit;

