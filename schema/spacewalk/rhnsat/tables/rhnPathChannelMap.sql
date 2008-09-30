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
	path		varchar2(128)
			constraint rhn_path_channel_map_p_nn not null,
	channel_id	number
			constraint rhn_path_channel_map_cid_nn not null
			constraint rhn_path_channel_map_cid_fk
				references rhnChannel(id) on delete cascade,
	is_source	varchar2(1),
	created		date default SYSDATE,
	modified	date default SYSDATE
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_path_channel_map_p_cid_uq 
	on rhnPathChannelMap(path, channel_id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;

create index rhn_path_channel_map_cid_p_idx
	on rhnPathChannelMap(channel_id, path)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_path_channel_map_mod_trig
before insert or update on rhnPathChannelMap
for each row
begin
	:new.modified := SYSDATE;
end rhn_beehive_mod_trig;
/
show errors

-- $Log$
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
