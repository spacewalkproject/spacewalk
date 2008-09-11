--
-- $Id$
--

-- When we ask "show me files that changed between X and Y dates", the dates
-- get stored here.
--

create table
rhnActionConfigDate
(
	action_id		number
				constraint rhn_actioncd_aid_nn not null
				constraint rhn_actioncd_aid_fk
					references rhnAction(id)
					on delete cascade,
	start_date		date
				constraint rhn_actioncd_start_nn not null,
	end_date		date,
	import_contents		char(1)
				constraint rhn_actioncd_file_ic_nn not null
				constraint rhn_actioncd_file_ic_ck
					check (import_contents in ('Y','N')),
	created			date default(sysdate)
				constraint rhn_actioncd_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_actioncd_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_actioncd_aid_uq
	on rhnActionConfigDate( action_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_actioncd_mod_trig
before insert or update on rhnActionConfigDate
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.3  2004/03/15 16:41:57  pjones
-- bugzilla: 118245 -- on delete cascades for deleting actions
--
-- Revision 1.2  2003/12/17 22:08:53  pjones
-- bugzilla: none -- move this column to the parent, not the blacklist info
--
-- Revision 1.1  2003/12/17 15:15:45  pjones
-- bugzilla: none ? -- add schema for import by date action
--
