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

create or replace view rhnChannelFamilyPermissions as
	select	channel_family_id,
		to_number(null) org_id,
		to_number(null) max_members,
		0 current_members,
		created,
		modified
	from	rhnPublicChannelFamily
	union
	select	channel_family_id,
		org_id,
		max_members,
		current_members,
		created,
		modified
	from	rhnPrivateChannelFamily;

-- -- we're not going to do the compat stuff the first time out
-- create or replace trigger
-- rhn_channel_perms_insert_trig
-- instead of insert on rhnChannelFamilyPermissions
-- for each row
-- begin
-- 	if :new.created is null then
-- 		:new.created := sysdate;
-- 	end if;
-- 	if :new.modified is null then
-- 		:new.modified := sysdate;
-- 	end if;
-- 	if :new.org_id is null then
-- 		insert into rhnPublicChannelFamily (
-- 				channel_family_id, created, modified
-- 			) values (
-- 				:new.channel_family_id,
-- 				:new.created,
-- 				:new.modified
-- 			);
-- 	else
-- 		if :new.current_members is null then
-- 			:new.current_members := 0;
-- 		end if;
-- 		insert into rhnPrivateChannelFamily (
-- 				channel_family_id,
-- 				org_id,
-- 				max_members,
-- 				current_members,
-- 				created,
-- 				modified
-- 			) values (
-- 				:new.channel_family_id,
-- 				:new.org_id,
-- 				:new.max_members,
-- 				:new.current_members,
-- 				:new.created,
-- 				:new.modified
-- 			);
-- 	end if;
-- end;
-- /
-- show errors

--
-- $Log$
-- Revision 1.2  2004/04/16 16:07:12  pjones
-- bugzilla: none -- 8.1.7 won't let you use "null foo" as a column in a view
-- that gets unioned with a typed column.  you have to use "to_number(null) foo".  What a load of crap.
--
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
