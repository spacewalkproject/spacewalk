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
rhnOrgChannelSettings
(
	org_id		numeric
			not null
			constraint rhn_orgcsettings_oid_fk
			references web_customer(id)
			on delete cascade,
	channel_id	numeric
			not null
			constraint rhn_orgcsettings_cid_fk
			references rhnChannel(id)
			on delete cascade,
	setting_id	numeric
			not null
			constraint rhn_orgcsettings_sid_fk
			references rhnOrgChannelSettingsType(id),
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null,
                        constraint rhn_orgcsettings_oid_cid_uq
                        unique(org_id, channel_id, setting_id)
--                      using index tablespace [[8m_tbs]]
)
  ;

/*
create or replace trigger
rhn_orgcsettings_mod_trig
before insert or update on rhnOrgChannelSettings
for each row
begin
	:new.modified := sysdate;	
end;
/
show errors
*/
--
-- Revision 1.3  2003/07/18 18:15:04  pjones
-- bugzilla: none -- shouldn't exclude this file ;)
--
-- Revision 1.2  2003/07/17 18:07:18  pjones
-- bugzilla: none
--
-- change this to be the new way which was discussed
--
-- Revision 1.1  2003/07/15 17:36:50  pjones
-- bugzilla: 98933
--
-- channel permissions
--
