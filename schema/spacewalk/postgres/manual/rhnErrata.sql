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

-- this is an errata.  Still needs some work, methinks.
-- maybe take all the varchar2(4000) fields and make them references to a 
-- id -> clob map?
create table
rhnErrata
(
        id              numeric not null
                        constraint rhn_errata_id_pk primary key,
--                        using index tablespace [[64k_tbs]],
        advisory        varchar(37) not null
			constraint rhn_errata_advisory_uq unique, 
--	        	tablespace [[64k_tbs]]
        advisory_type   varchar(32) not null
			constraint rhn_errata_adv_type_ck
			           check (advisory_type in ('Bug Fix Advisory',
				                            'Product Enhancement Advisory',
							    'Security Advisory')),
      	advisory_name	varchar(32) not null
			constraint rhn_errata_advisory_name_uq unique,
--       		tablespace [[64k_tbs]]
	advisory_rel	numeric not null,
        product         varchar(64) not null,
        description     varchar(4000), -- description
        synopsis        varchar(4000) not null,
        topic           varchar(4000), -- Problem description
                                      -- XXX: blob maybe - its all text
        solution        varchar(4000) not null,
        issue_date      timestamp default (current_timestamp) not null,
        update_date     timestamp default (current_timestamp) not null,
        refers_to	varchar(4000),
        notes           varchar(4000),
        org_id          numeric
                        constraint rhn_errata_oid_fk
                                references web_customer(id)
				on delete cascade,
       locally_modified char(1)
			constraint rhn_errata_lm_ck check
				(locally_modified in ('Y','N')),
        created         timestamp default (current_timestamp) not null,
        modified        timestamp default (current_timestamp) not null,
	last_modified	timestamp default (current_timestamp) not null,
        severity_id     numeric
                        constraint rhn_errata_sevid_fk
                                references rhnErrataSeverity(id)
)
  ;

create sequence rhn_errata_id_seq;

--
-- Revision 1.22  2004/11/01 21:47:41  pjones
-- bugzilla: none -- rhnErrata's triggers need other tables now
--
-- Revision 1.21  2004/11/01 15:17:52  pjones
-- bugzilla: none -- typo fix.
--
-- Revision 1.20  2004/10/29 18:11:45  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.19  2003/08/15 17:03:55  rnorwood
-- bugzilla: 101692 - add flow for cloning channels.
--
-- Revision 1.18  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.17  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.16  2002/07/31 00:12:33  cturner
-- enlarge rhnErrata.product for stronghold errata
--
-- Revision 1.15  2002/04/30 00:20:48  misa
-- Added non-null constraints to rhnErrata
--
-- Revision 1.14  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.13  2002/02/22 22:07:20  cturner
-- put some constraints on this field that keeps acting funny
--
-- Revision 1.12  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.11  2001/12/27 18:22:01  pjones
-- policy change: foreign keys to other users' tables now _always_ go to
-- a synonym.  This makes satellite schema (where web_contact is in the same
-- namespace as rhn*) easier.
--

