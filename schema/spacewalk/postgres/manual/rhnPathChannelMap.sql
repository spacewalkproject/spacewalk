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

create table rhnPathChannelMap
(
	path		varchar(128)
			not null,
	channel_id	numeric
			not null
			constraint rhn_path_channel_map_cid_fk
			references rhnChannel(id) on delete cascade,
	is_source	varchar(1),
	created		date default CURRENT_DATE,
	modified	date default CURRENT_DATE,
                        constraint rhn_path_channel_map_p_cid_uq
                        unique (path, channel_id)
--                      using index tablespace [[64k_tbs]]
)
  ;

create index rhn_path_channel_map_cid_p_idx
	on rhnPathChannelMap(channel_id, path)
--	tablespace [[64k_tbs]]
	;

/*
create or replace trigger
rhn_path_channel_map_mod_trig
before insert or update on rhnPathChannelMap
for each row
begin
	:new.modified := SYSDATE;
end rhn_beehive_mod_trig;
/
show errors
*/
--
-- Revision 1.12  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.11  2002/05/20 13:34:26  pjones
-- on delete cascade for rhnChannel foreign keys
--
-- Revision 1.10  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
