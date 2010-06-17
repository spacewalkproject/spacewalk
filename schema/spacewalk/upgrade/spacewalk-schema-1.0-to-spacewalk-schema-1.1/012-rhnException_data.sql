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
-- data for rhnException

insert into rhnException values (-20294, 'not_enough_flex_entitlements_in_base_org', 'You do not have enough entitlements in the base org.');
insert into rhnException values (-20295, 'server_cannot_convert_to_flex', 'The given server cannot be converted to a flex entitlement.');

insert into rhnException values (-20296, 'not_enough_flex_entitlements', 'You do not have enough entitlements in your org..');
commit;


