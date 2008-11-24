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

ALTER TABLE rhnKickstartDefaults
 ADD virt_guest_name varchar2(256);
 
ALTER TABLE rhnKickstartDefaults
 ADD virt_mem_kb number;
 
ALTER TABLE rhnKickstartDefaults
 ADD virt_vcpus number;
 
ALTER TABLE rhnKickstartDefaults
 ADD virt_disk_gb number;
 
ALTER TABLE rhnKickstartDefaults
 ADD virt_bridge varchar2(256);

show errors


-- $Log$
-- Revision 1  2008/11/24 7:01:05  mmccune
-- add new virt fields
