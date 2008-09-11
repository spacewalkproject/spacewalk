--
-- $Id$
--

create table
rhnPoll
(
        id              number
			constraint rhn_poll_id_nn not null
                        constraint rhn_poll_id_pk primary key
				using index tablespace rhn_ind
				storage ( initial 40960 
					next 507904 pctincrease 1 ),
	name		varchar2(512)
			constraint rhn_poll_name_nn not null,
	state_id	number
			constraint rhn_poll_sid_nn not null
			constraint rhn_poll_sid_fk
				references rhnPollState(id),
	begin_date	date default(sysdate)
			constraint rhn_poll_begin_nn not null,
	end_date	date default(sysdate)
			constraint rhn_poll_end_nn not null,
	created		date default(sysdate)
			constraint rhn_poll_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_poll_modified_nn not null
)
storage ( initial 40960 next 5816320 pctincrease 1 );

create sequence rhn_poll_id_seq;

create or replace trigger
rhn_poll_mod_trig
before insert or update on rhnPoll
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.2  2001/12/10 22:29:27  pjones
-- add poll state and begin/end dates
--
-- Revision 1.1  2001/12/10 22:19:09  pjones
-- initial checkin of user poll schema
--
