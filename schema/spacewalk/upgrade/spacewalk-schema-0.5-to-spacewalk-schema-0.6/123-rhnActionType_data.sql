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

update rhnActionType
set name = 'Initiate a kickstart for a virtual guest.'
where label = 'kickstart_guest.initiate';

update rhnActionType
set name = 'Shuts down a virtual domain.'
where label = 'virt.shutdown';

update rhnActionType
set name = 'Starts up a virtual domain.'
where label = 'virt.start';

update rhnActionType
set name = 'Suspends a virtual domain.'
where label = 'virt.suspend';

update rhnActionType
set name = 'Resumes a virtual domain.'
where label = 'virt.resume';

update rhnActionType
set name = 'Reboots a virtual domain.'
where label = 'virt.reboot';

update rhnActionType
set name = 'Destroys a virtual domain.'
where label = 'virt.destroy';

update rhnActionType
set name = 'Sets the maximum memory usage for a virtual domain.'
where label = 'virt.setMemory';

update rhnActionType
set name = 'Sets the Vcpu usage for a virtual domain.'
where label = 'virt.setVCPUs';
