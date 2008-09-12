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
-- EXCLUDE: all
--

create table
rhnServerHardware
(
	server_id		number
				constraint rhn_serverhw_sid_nn not null
				constraint rhn_serverhw_sid_fk
					references rhnServer(id),
	hardware_id		number
				constraint rhn_serverhw_hid_nn not null
				constraint rhn_serverhw_hid_fk
					references rhnHardware(id),
	created			date default(sysdate)
				constraint rhn_serverhw_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_serverhw_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_serverhw_sid_hid_idx
	on rhnServerHardware ( server_id, hardware_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_serverhw_mod_trig
before insert or update on rhnServerHardware
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.3  2003/08/20 16:36:07  pjones
-- bugzilla: none
--
-- disable rhnHardware
--
-- Revision 1.2  2003/03/10 15:49:10  pjones
-- add fk constraints
--
-- Revision 1.1  2003/02/27 00:35:12  pjones
-- new hardware tables
-- lookup functions and conversion scripts to come tomorrow
-- Also todo: makefile.deps
--
