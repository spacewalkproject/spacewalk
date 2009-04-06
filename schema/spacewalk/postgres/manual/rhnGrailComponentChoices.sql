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
--/

create table
rhnGrailComponentChoices
(
        user_id         numeric
                        not null
                        constraint rhn_grail_comp_ch_user_fk
                        references web_contact(id)
			on delete cascade,
        ordering        numeric
                        not null,
        component_pkg   varchar(64)
                        not null,
        component_mode  varchar(64)
                        not null,
                        constraint rhn_grail_comp_ch_user_ord_uq
                        unique(user_id,ordering)
--                      using index tablespace [[64k_tbs]]
)

  ;


create index rhn_grail_cmp_ch_user
	on rhnGrailComponentChoices(user_id)
--	tablespace [[64k_tbs]]
	;

--
--
-- Revision 1.10  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.7  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.6  2001/12/27 18:22:01  pjones
-- policy change: foreign keys to other users' tables now _always_ go to
-- a synonym.  This makes satellite schema (where web_contact is in the same
-- namespace as rhn*) easier.
--
-- Revision 1.5  2001/07/25 09:03:04  pjones
-- make fk's not use synonyms
--
-- Revision 1.4  2001/07/24 22:17:00  cturner
-- nologging on a bunch of indexes... fun
--
-- Revision 1.3  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.2  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.1  2001/06/27 02:26:25  pjones
-- pxt and grail
--
--
--/
