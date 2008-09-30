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
-- What a package delta looks like; this is subtly diffirent from an
-- rhnTransaction/rhnTransactionElement pair.  In particular:
-- . no transaction ID -- this is not a transaction that has happened
-- . no timestamp -- same reason
-- . no server_id -- this gets associated with an action, and that has a 
--                   server_id already
--
-- note that basically this only exists because we want labeling of deltas.
-- without that, it'd just be rhnActionPackageDelta -> rhnTransactionPackage

create sequence rhn_packagedelta_id_seq;

create table
rhnPackageDelta
(
	id		number
			constraint	rhn_packagedelta_id_nn not null,
	label		varchar2(32)
			constraint	rhn_packagedelta_label_nn not null,
	created		date default(sysdate)
			constraint	rhn_packagedelta_created_nn not null,
	modified	date default(sysdate)
			constraint	rhn_packagedelta_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_packagedelta_label_id_idx
	on rhnPackageDelta(label, id)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhnPackageDelta add
	constraint rhn_packagedelta_id_pk primary key (id)
	using index tablespace [[4m_tbs]];

create or replace trigger
rhn_packagedelta_mod_trig
before insert or update on rhnPackageDelta
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.2  2003/06/10 23:00:14  pjones
-- bugzilla: none
--
-- typo
--
-- Revision 1.1  2003/06/10 19:42:25  pjones
-- package delta actions
--
