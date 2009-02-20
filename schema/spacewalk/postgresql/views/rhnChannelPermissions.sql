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

create or replace view
rhnChannelPermissions
(
    org_id, channel_id
)
as
select distinct org_id, channel_id
 from ( select privcf.org_id,
               cfm.channel_id
        from   rhnChannelFamilyMembers cfm,
               rhnPrivateChannelFamily privcf
        where  privcf.channel_family_id = cfm.channel_family_id
       union all
       select  u.org_id, cfm.channel_id
       from    web_contact u,
               rhnChannelFamilyMembers cfm,
               rhnPublicChannelFamily pubcf
       where   pubcf.channel_family_id = cfm.channel_family_id
) S;

