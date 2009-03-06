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
	id		numeric not null
			constraint rhn_packagedelta_id_pk primary key,
--        		using index tablespace [[4m_tbs]]
	label		varchar(32) not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
  ;

create index rhn_packagedelta_label_id_idx
	on rhnPackageDelta(label, id)
--	tablespace [[8m_tbs]]
  ;

/*
create or replace trigger
rhn_packagedelta_mod_trig
before insert or update on rhnPackageDelta
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.2  2003/06/10 23:00:14  pjones
-- bugzilla: none
--
-- typo
--
-- Revision 1.1  2003/06/10 19:42:25  pjones
-- package delta actions
--
