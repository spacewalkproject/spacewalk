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

create table rhnSGTypeVirtSubLevel (
    server_group_type_id    numeric
                            not null
                            constraint rhn_sgtvsl_sgtid_fk
                            references rhnServerGroupType(id),
    virt_sub_level_id       numeric
                            not null
                      constraint rhn_sgtvsl_vslid_fk
                        references rhnVirtSubLevel(id),
    created           date
                      default current_date
                      not null,
    modified          date
                      default current_date
                      not null
)
  ;

create index rhn_sgtvsl_sgtid_vslid
    on rhnSGTypeVirtSubLevel(server_group_type_id, virt_sub_level_id)
--    tablespace [[64k_tbs]]
  ;

create index rhn_sgtvsl_vslid_sgtid
    on rhnSGTypeVirtSubLevel(virt_sub_level_id, server_group_type_id)
--    tablespace [[64k_tbs]]
  ;




                                    
