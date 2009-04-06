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
rhnRegTokenOrgDefault
(
	org_id		numeric not null
			constraint rhn_reg_token_def_oid_fk
				references web_customer(id)
				on delete cascade,
	reg_token_id	numeric
			constraint rhn_reg_token_def_tokid_fk
				references rhnRegToken(id)
				on delete cascade
)
;

create unique index rhn_reg_token_def_org_id_idx
	on rhnRegTokenOrgDefault(org_id)
  ;

create index rhn_reg_token_def_uid_idx
	on rhnRegTokenOrgDefault (reg_token_id, org_id)
  ;
	
