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
-- $Id$
--
-- This is a log of all changes to server group counts and family permission
-- counts
--
-- EXCLUDE: all

create table
rhnSatelliteLog
(
	customer_id	number
			constraint rhn_satellite_log_cid_nn not null
			constraint rhn_satellite_log_cid_fk
				references web_customer(id),
	ugsg		char(1)
			constraint rhn_satellite_log_ugsg_ck
				check (ugsg in ('U','S')),
	group_type	number,
	id		number
			constraint rhn_satellite_log_id_nn not null,
	quantity	number
			constraint rhn_satellite_log_quantity_nn not null,
	created		date default(sysdate)
			constraint rhn_satellite_log_created_nn not null,
	modified	date default(sysdate)
)
	storage( freelists 16 )
	initrans 32;

create or replace trigger
rhn_satellite_log_ins_trig
before insert or update on rhnSatelliteLog
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

create or replace trigger
rhn_cfp_log_trig
before insert or update on rhnPrivateChannelFamily
for each row
begin
	insert into rhnSatelliteLog values (
		:new.org_id,
		null,
		null,
		:new.channel_family_id,
		:new.max_members,
		sysdate,
		sysdate
	);
end;
/
show errors

create or replace trigger
rhn_sg_log_trig
before insert or update on rhnServerGroup
for each row
begin
	insert into rhnSatelliteLog values (
		:new.org_id,
		'S',
		:new.group_type,
		:new.id,
		:new.max_members,
		sysdate,
		sysdate
	);
end;
/
show errors

create or replace trigger
rhn_ug_log_trig
before insert or update on rhnUserGroup
for each row
begin
	insert into rhnSatelliteLog values (
		:new.org_id,
		'U',
		:new.group_type,
		:new.id,
		:new.max_members,
		sysdate,
		sysdate
	);
end;
/
show errors

-- $Log$
-- Revision 1.4  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
