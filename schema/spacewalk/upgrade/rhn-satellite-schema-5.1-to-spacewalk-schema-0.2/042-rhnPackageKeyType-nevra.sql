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
rhnPackageKeyType
(
	id		number
			constraint rhn_pkg_key_type_id_nn not null,
	label		varchar2(64)
			constraint rhn_pkg_key_type_label_nn not null,
	created		date default(sysdate)
			constraint rhn_pkg_key_type_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_pkg_key_type_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_package_key_type_id_seq start with 100;

-- these must be in this order.
create index rhn_pkg_key_type_id_n_idx
	on rhnPackageKeyType(id,label)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnPackageKeyType add constraint rhn_pkg_key_type_id_pk primary key (id);
alter table rhnPackageKeyType add constraint rhn_pkg_key_type_label_uq unique ( label );



create or replace trigger
rhn_pkg_key_type_mod_trig
before insert or update on rhnPackageKeyType
for each row
begin
        :new.modified := sysdate;
end;
/

show errors

-- $Log$
-- Revision 1.1  2008/07/01 21:50:21  jsherrill
-- new package key tracking 
--
