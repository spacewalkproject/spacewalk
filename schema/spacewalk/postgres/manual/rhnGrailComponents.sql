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
rhnGrailComponents
(
        id              numeric
                        constraint rhn_grail_comp_pk primary key
--                      using index tablespace [[64k_tbs]]
                        ,
        component_pkg   varchar(64)
                        not null,
        component_mode  varchar(64)
                        not null,
        config_mode     varchar(64),
        component_label varchar(128) 
                        constraint rhn_grail_comp_label_uq unique,
        role_required   numeric
                        constraint rhn_grail_comp_role_type_fk
                        references rhnUserGroupType(id),
                        constraint rhn_grail_comp_pkg_mode_uq
                        unique (component_pkg, component_mode)
--                      using index tablespace [[64k_tbs]]
)
  ;

create sequence rhn_grail_components_seq;


-- 
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.4  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
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
