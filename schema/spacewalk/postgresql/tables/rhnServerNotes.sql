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
rhnServerNotes
(
        id              numeric
                        not null
                        constraint rhn_servernotes_id_pk primary key
--                      using index tablespace [[64k_tbs]]
                        ,
        creator         numeric
                        constraint rhn_servernotes_creator_fk
                                   references web_contact(id)
				   on delete set null,
        server_id       numeric
                        not null
                        constraint rhn_servernotes_sid_fk
                                   references rhnServer(id),
        subject         varchar(80)
                        not null,
        note            varchar(4000),
        created         date default(current_date)
                        not null,
        modified        date default(current_date)
                        not null
)
  ;

create sequence rhn_server_note_id_seq;

create index rhn_servernotes_sid_idx
	on rhnServerNotes(server_id)
--	tablespace [[64k_tbs]]
	;

create index rhn_servernotes_creator_idx
	on rhnServerNotes ( creator )
--	tablespace [[64k_tbs]]
	;

/*
create or replace trigger
rhn_servernotes_mod_trig
before insert or update on rhnServerNotes
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.17  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.16  2003/04/02 17:18:20  pjones
-- Kill the not nulls on things we're setting null.
--
-- Revision 1.15  2003/04/02 17:00:04  pjones
-- bugzilla: none
--
-- fix some spots we missed on user del path.
--
-- To find these, do
--
-- select table_name, constraint_name, delete_rule from all_constraints
-- where r_constraint_name = 'WEB_CONTACT_PK'
--         and delete_rule not in ('CASCADE','SET NULL')
--
-- Note that right now in webqa and web there's a "WEB_UBERBLOB" table that's
-- not got the constraints that live does.  how quaint.
--
-- Revision 1.14  2003/03/27 21:10:23  pjones
-- indices to support faster user deletion
--
-- Revision 1.13  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
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
