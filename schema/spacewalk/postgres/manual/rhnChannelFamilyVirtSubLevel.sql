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

create table rhnChannelFamilyVirtSubLevel (
    channel_family_id numeric
                      not null
                      constraint rhn_cfvsl_cfid_fk 
                      references rhnChannelFamily(id),
    virt_sub_level_id numeric
                      not null
                      constraint rhn_cfvsl_vslid_fk
                      references rhnVirtSubLevel(id),
    created           date default current_date
                      not null,
    modified          date default current_date
                      not null
)
  ;

create index rhn_cfvsl_cfid_vslid_idx
    on rhnChannelFamilyVirtSubLevel(channel_family_id, virt_sub_level_id)
--    tablespace [[64k_tbs]]
  ;

create index rhn_cfvsl_vslid_cfid_idx
    on rhnChannelFamilyVirtSubLevel(virt_sub_level_id, channel_family_id)
--    tablespace [[64k_tbs]]
  ;




