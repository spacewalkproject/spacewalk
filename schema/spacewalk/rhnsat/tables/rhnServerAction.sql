--
-- Copyright (c) 2008 Red Hat, Inc.
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
--
--
--

create table
rhnServerAction
(
        server_id       number
			constraint rhn_server_action_sid_nn not null
                        constraint rhn_server_action_sid_fk
                        references rhnServer(id),
        action_id       number
			constraint rhn_server_action_aid_nn not null
                        constraint rhn_server_action_aid_fk
                        references rhnAction(id) on delete cascade,
        status          number
			constraint rhn_server_action_status_nn not null
                        constraint rhn_server_action_status_fk
                        references rhnActionStatus(id),
        result_code     number,
        result_msg      varchar(1024),
        pickup_time     date,
	remaining_tries	number default(5)
			constraint rhn_server_action_remaining_nn not null,
        completion_time	date,
        created         date default (sysdate)
			constraint rhn_server_action_created_nn not null,
        modified        date default (sysdate)
			constraint rhn_server_action_modified_nn not null
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

-- you can't create foreign keys to column lists made unique by 
-- "create unique index".  shame on you, oracle.
create index rhn_ser_act_sid_aid_s_idx
        on rhnServerAction(server_id, action_id, status)
        tablespace [[8m_tbs]]
        storage( freelists 16 )
        initrans 32;

alter table rhnServerAction
	add constraint rhn_server_action_sid_aid_uq
	unique ( server_id, action_id );
	
create index rhn_ser_act_aid_sid_s_idx
	on rhnServerAction(action_id, server_id, status)
	tablespace [[8m_tbs]]
	storage( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_server_action_mod_trig
before insert or update on rhnServerAction
for each row
declare
	handle_status	number;
begin
	:new.modified := sysdate;
	handle_status := 0;
	if updating then
		if :new.status != :old.status then
			handle_status := 1;
		end if;
	else
		handle_status := 1;
	end if;

	if handle_status = 1 then
		if :new.status = 1 then
			:new.pickup_time := sysdate;
		elsif :new.status = 2 then
			:new.completion_time := sysdate;
		end if;
	end if;
end;
/
show errors

-- $Log$
-- Revision 1.17  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.16  2003/10/16 18:13:10  pjones
-- bugzilla: none
-- rhnActionConfigFile points to rendered paths for config files,
-- so it's per server
--
-- Revision 1.15  2003/08/25 14:59:44  pjones
-- bugzilla: none
--
-- fix rhnAction cascades
--
-- Revision 1.14  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.13  2003/01/15 23:37:39  pjones
-- retry count on rhnserverAction
--
-- Revision 1.12  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
