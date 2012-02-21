-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8
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
-- triggers for rhnChannelPackage

drop trigger rhn_channel_package_mod_trig on rhnChannelCloned;

create trigger
rhn_channel_package_mod_trig
before insert or update on rhnChannelPackage
for each row
execute procedure rhn_channel_package_mod_trig_fun();
