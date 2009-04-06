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
rhnUserServerPrefs
(
        user_id		numeric
                        not null
                        constraint rhn_userServerPrefs_uid_fk
                                references web_contact(id)
				on delete cascade,
        server_id	numeric
                        not null
                        constraint rhn_userServerPrefs_sid_fk
                                references rhnServer(id),
        name            varchar(64)
                        not null,
        value           varchar(1)
                        not null,
        created         date default(current_date)
                        not null,
        modified        date default(current_date)
                        not null,
                        constraint rhn_usprefs_uid_sid_n_uq
                        unique(user_id, server_id, name)
--                        using index tablespace [[2m_tbs]]
)
 ;

create index rhn_usprefs_n_sid_uid_idx
	on rhnUserServerPrefs(name, server_id, user_id)
--	tablespace [[2m_tbs]]
 ;

create index rhn_usprefs_sid_uid_n_idx
	on rhnUserServerPrefs(server_id, user_id, name)
--	tablespace [[2m_tbs]]
 ;
	
--create or replace trigger
--rhn_u_s_prefs_mod_trig
--before insert or update on rhnUserServerPrefs
--for each row
--begin
--        :new.modified := sysdate;
--        :new.value := upper(:new.value);
--end;
--/
--show errors
--
--
-- Revision 1.13  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.12  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.11  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.10  2002/10/08 21:42:48  pjones
-- index starting with server_id on rhnUserServerPrefs
--
-- Revision 1.9  2002/05/10 22:00:49  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
