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

create sequence rhn_hardware_id_seq;

create table
rhnHardware
(
	id			number
				constraint rhn_hardware_id_nn not null,
	num_props		number
				constraint rhn_hardware_np_nn not null,
	class			varchar2(16),
	bus			varchar2(32),
	description		varchar2(256),
	csum			number
				constraint rhn_hardware_csum_nn not null,
	created			date default(sysdate),
	modified		date default(sysdate)
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_hardware_id_idx
	on rhnHardware ( id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnHardware add constraint rhn_hardware_id_pk primary key ( id );
create index rhn_hwardware_csum_id_idx
	on rhnHardware ( csum, id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnHardware add constraint rhn_hardware_csum_uq
	unique ( csum );

create or replace trigger
rhn_hardware_mod_trig
before insert or update on rhnHardware
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.5  2003/08/20 16:36:07  pjones
-- bugzilla: none
--
-- disable rhnHardware
--
-- Revision 1.4  2003/07/01 13:11:20  misa
-- bugzilla: none  modified field was missing
--
-- Revision 1.3  2003/06/19 22:08:46  pjones
-- bugzilla: 84125
--
-- New hardware schema.  This looks pretty final, but conversion is still
-- a work in progress.
--
-- Revision 1.2  2003/03/10 15:49:10  pjones
-- add fk constraints
--
-- Revision 1.1  2003/02/27 00:35:12  pjones
-- new hardware tables
-- lookup functions and conversion scripts to come tomorrow
-- Also todo: makefile.deps
--
