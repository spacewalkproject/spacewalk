--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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
alter trigger rhn_channel_mod_trig disable;
ALTER TABLE rhnChannel
ADD channel_access  varchar2(10) default 'private';
alter trigger rhn_channel_mod_trig enable;

ALTER TABLE rhnChannel
ADD maint_name  varchar2(128);

ALTER TABLE rhnChannel
ADD maint_email  varchar2(128);

ALTER TABLE rhnChannel
ADD maint_phone  varchar2(128);

ALTER TABLE rhnChannel
ADD support_policy  varchar2(256);



create index rhn_channel_access_idx
	on rhnChannel(channel_access)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create or replace trigger rhn_channel_access_trig
after update on rhnChannel
for each row
begin
   if :old.channel_access = 'protected' and
      :new.channel_access != 'protected'
   then
      delete from rhnChannelTrust where channel_id = :old.id;
   end if;
end;
/
show errors

