--
--$Id$
--
-- 
--

--data for rhn_schedule_days
--only include the 24 x 7 schedule

insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( rhn_schedule_days_recid_seq.nextval,1,0,
    to_date('08-SEP-2000 12:00:02 AM','DD-MON-YYYY HH:MI:SS AM'),
    to_date('09-SEP-2000 12:00:00 AM','DD-MON-YYYY HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( rhn_schedule_days_recid_seq.nextval,1,1,
    to_date('08-SEP-2000 12:00:09 AM','DD-MON-YYYY HH:MI:SS AM'),
    to_date('09-SEP-2000 12:00:00 AM','DD-MON-YYYY HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( rhn_schedule_days_recid_seq.nextval,1,2,
    to_date('08-SEP-2000 12:00:14 AM','DD-MON-YYYY HH:MI:SS AM'),
    to_date('09-SEP-2000 12:00:00 AM','DD-MON-YYYY HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( rhn_schedule_days_recid_seq.nextval,1,3,
    to_date('08-SEP-2000 12:00:20 AM','DD-MON-YYYY HH:MI:SS AM'),
    to_date('09-SEP-2000 12:00:00 AM','DD-MON-YYYY HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( rhn_schedule_days_recid_seq.nextval,1,4,
    to_date('08-SEP-2000 12:00:25 AM','DD-MON-YYYY HH:MI:SS AM'),
    to_date('09-SEP-2000 12:00:00 AM','DD-MON-YYYY HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( rhn_schedule_days_recid_seq.nextval,1,5,
    to_date('08-SEP-2000 12:00:31 AM','DD-MON-YYYY HH:MI:SS AM'),
    to_date('09-SEP-2000 12:00:00 AM','DD-MON-YYYY HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
insert into rhn_schedule_days(recid,schedule_id,ord,start_1,end_1,start_2,
end_2,start_3,end_3,start_4,end_4,last_update_user,last_update_date) 
    values ( rhn_schedule_days_recid_seq.nextval,1,6,
    to_date('08-SEP-2000 12:00:36 AM','DD-MON-YYYY HH:MI:SS AM'),
    to_date('09-SEP-2000 12:00:00 AM','DD-MON-YYYY HH:MI:SS AM'),
    null,null,null,null,null,null,'system',null);
commit;

--$Log$
--Revision 1.5  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.4  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.3  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/22 19:05:45  kja
--Added the 24 x 7 schedule data.  Corrected logic for skipping sequence numbers
--in rhn_notification_formats_data.sql and rhn_strategies_data.sql.
--
