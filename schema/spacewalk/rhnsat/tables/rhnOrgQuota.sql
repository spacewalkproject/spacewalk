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
rhnOrgQuota
(
	org_id		number
			constraint rhn_orgquota_oid_nn not null
			constraint rhn_orgquota_oid_fk
				references web_customer(id),
	total		number default(0)
			constraint rhn_orgquota_total_nn not null,
	bonus		number default(0)
			constraint rhn_orgquota_bonus_nn not null,
	used		number default(0)
			constraint rhn_orgquota_used_nn not null,
	created		date default(sysdate)
			constraint rhn_orgquota_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_orgquota_mod_nn not null
)
	enable row movement
  ;

create unique index rhn_orgquota_oid_uq
	on rhnOrgQuota(org_id)
	tablespace [[2m_tbs]]
  ;

create or replace trigger
rhn_orgquota_mod_trig
before insert or update on rhnOrgQuota
for each row
declare
	available_quota number;
begin
	:new.modified := sysdate;

	available_quota := :new.total + :new.bonus;
	if :new.used > available_quota then
		rhn_exception.raise_exception('not_enough_quota');
	end if;
end;
/
show errors

--
--
-- Revision 1.1  2003/12/19 22:07:30  pjones
-- bugzilla: 112392 -- quota support for config files
--
