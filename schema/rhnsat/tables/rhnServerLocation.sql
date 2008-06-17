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
-- $Id$
--

create table
rhnServerLocation
(
        id              number
			constraint rhn_serverlocation_id_nn not null
                        constraint rhn_serverlocation_id_pk primary key
				using index tablespace [[64k_tbs]],
        server_id       number
			constraint rhn_serverlocation_sid_nn  not null
                        constraint rhn_serverlocation_sid_fk
                                references rhnServer(id),
        machine         varchar2(64),
        rack            varchar2(64),
        room            varchar2(32),
        building        varchar2(128),
        address1        varchar2(128),
        address2        varchar2(128),
        city            varchar2(128),
        state           varchar2(60),
        country         char(2),
        created         date default (sysdate)
			constraint rhn_serverlocation_created_nn not null,
        modified        date default (sysdate)
			constraint rhn_serverlocation_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_server_loc_id_seq;

create unique index rhn_serverlocation_sid_uq
	on rhnServerLocation ( server_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_serverlocation_mod_trig
before insert or update on rhnServerLocation
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.13  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.12  2003/05/05 21:50:36  pjones
-- need an index on rhnServerLocation.server_id, and soon.
--
-- Revision 1.11  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.10  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
