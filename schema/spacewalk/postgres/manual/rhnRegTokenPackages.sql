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
rhnRegTokenPackages
(
        id              numeric not null
                        constraint rhn_reg_tok_pkg_id_pk primary key,

	token_id	numeric not null
			constraint rhn_reg_tok_pkg_id_fk
				references rhnRegToken(id)
				on delete cascade,
        name_id         numeric not null
                        constraint rhn_reg_tok_pkg_sgs_fk
                                references rhnPackageName(id)
				on delete cascade,
        arch_id         numeric
                        constraint rhn_reg_tok_pkg_aid_fk
                                references rhnPackageArch(id)
                                on delete cascade
)
 ;

create unique index rhn_reg_tok_pkg_uq
	on rhnRegTokenPackages(id, token_id, name_id, arch_id)
--	tablespace [[4m_tbs]]
  ;

-- need this for delete cascade speed
create index rhn_reg_tok_pkg_nid_idx
	on rhnRegtokenPackages(name_id)
--	tablespace [[2m_tbs]]
  ;

create sequence rhn_reg_tok_pkg_id_seq;

