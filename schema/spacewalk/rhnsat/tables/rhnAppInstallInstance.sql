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

create sequence rhn_appinst_instance_id_seq;

create table
rhnAppInstallInstance
(
	id		number
			constraint rhn_appinst_instance_id_nn not null,
	name		varchar2(128)
			constraint rhn_appinst_instance_name_nn not null,
	label		varchar2(128)
			constraint rhn_appinst_instance_label_nn not null,
	version		varchar2(32)
			constraint rhn_appinst_instance_vers_nn not null,
	created		date default (sysdate)
			constraint rhn_appinst_instance_creat_nn not null,
	modified	date default (sysdate)
			constraint rhn_appinst_instance_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create or replace trigger
rhn_appinst_istance_mod_trig
before insert or update on rhnAppInstallInstance
for each row
begin
	:new.modified := sysdate;
end rhn_appinst_istance_mod_trig;
/
show errors

create index rhn_appinst_instance_id_idx
	on rhnAppInstallInstance( id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnAppInstallInstance add constraint rhn_appinst_instance_id_pk
	primary key ( id );

create index rhn_appinst_instance_lv_id_idx
	on rhnAppInstallInstance( label, version, id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnAppInstallInstance add constraint rhn_appinst_instance_lv_uq
	unique ( label, version );

--
-- $Log$
-- Revision 1.1  2004/09/16 22:40:55  pjones
-- bugzilla: 132546 -- tables for application installation.
--
