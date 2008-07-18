--
--$Id$
--
--

--schedule_days_norm current prod row count = 308
create table 
rhn_schedule_days_norm
(
    schedule_id     number   (12),
    ord             number   (3),
    start_int       number   (12),
    end_int         number   (12)        
)
	enable row movement
	;

--$Log$
--Revision 1.2  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
