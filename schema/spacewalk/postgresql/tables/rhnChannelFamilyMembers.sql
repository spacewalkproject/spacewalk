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
rhnChannelFamilyMembers
(
        channel_id            numeric
                              not null
                              constraint rhn_cf_members_c_fk
                              references rhnChannel(id) on delete cascade
                              constraint rhn_cf_c_uq unique
--                            using index tablespace [[64k_tbs]]
                              ,
        channel_family_id     numeric
                              not null
                              constraint rhn_cf_family_fk
                              references rhnChannelFamily(id),
        created               date default(current_date)
                              not null,
        modified              date default(current_date)
                              not null,
                              constraint rhn_cf_member_uq
                              unique(channel_id, channel_family_id)
--                            using index tablespace [[64k_tbs]]
)
  ;

-- a channel can be in at most one family

create index rhn_cf_member_cf_c_idx
	on rhnChannelFamilyMembers(channel_family_id, channel_id)
--	tablespace [[64k_tbs]]
	;

/*
create or replace trigger
rhn_cf_member_mod_trig
before insert or update on rhnChannelFamilyMembers
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.25  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.24  2002/05/10 21:54:44  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
