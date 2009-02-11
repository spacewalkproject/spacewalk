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
-- this matches errata <-> CVE/CAN strings, if any
--
create table
rhnErrataCVE
(
	errata_id	numeric not null constraint rhn_err_cve_eid_fk
				references rhnErrata(id)
				on delete cascade,
	cve_id	        numeric not null constraint rhn_err_cve_cid_fk
				references rhnCVE(id),
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
;

create unique index rhn_err_cve_eid_cid_uq
	on rhnErrataCVE(errata_id, cve_id)
--	tablespace [[64k_tbs]]
  ;

create index rhn_err_cve_cid_eid_idx
	on rhnErrataCVE(cve_id, errata_id)
--	tablespace [[64k_tbs]]
--	nologging
;
