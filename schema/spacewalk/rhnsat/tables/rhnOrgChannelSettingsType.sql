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

create sequence rhn_ocstngs_type_id_seq;

create table
rhnOrgChannelSettingsType
(
	id		number
			constraint rhn_ocstngs_type_id_nn not null
			constraint rhn_ocstngs_type_id_pk primary key,
	label		varchar2(32)
			constraint rhn_ocstngs_type_label_nn not null,
	created		date default(sysdate)
			constraint rhn_ocstngs_type_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_ocstngs_type_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_ocstngs_type_l_id_idx
	on rhnOrgChannelSettingsType( label, id )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_orgcsettings_type_mod_trig
before insert or update on rhnOrgChannelSettingsType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.1  2003/07/17 18:07:18  pjones
-- bugzilla: none
--
-- change this to be the new way which was discussed
--
