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
rhnPackageKey
(
	id		numeric
	                constraint rhn_pkey_id_pk primary key,
        key_id		varchar(64)
			not null
                        constraint rhn_pkey_keyid_uq unique,
	key_type_id	numeric
			not null
                        constraint rhn_pkey_type_id_prid_fk
                        references rhnPackageKeyType(id),
	provider_id	numeric
                        constraint rhn_pkey_prid_fk
			references rhnPackageProvider(id),
	created		date default(current_date)
		        not null,
	modified	date default(current_date)
			not null
)
  ;

create sequence rhn_pkey_id_seq start with 100;

-- these must be in this order.
create index rhn_pkey_id_k_pid_idx
	on rhnPackageKey(id,key_id,provider_id,key_type_id)
--	tablespace [[2m_tbs]]
  ;


/*
create or replace trigger
rhn_pkg_gpg_mod_trig
before insert or update on rhnPackageKey
for each row
begin
        :new.modified := sysdate;
end;
/

show errors
*/
--
-- Revision 1.1  2008/07/01 21:50:21  jsherrill
-- new package key tracking 
--
