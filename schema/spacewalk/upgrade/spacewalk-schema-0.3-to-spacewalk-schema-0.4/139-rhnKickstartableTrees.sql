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

update rhnKickstartableTree set boot_image='spacewalk-koan';

ALTER TABLE rhnKickstartableTree 
    MODIFY( boot_image  varchar2(128) default('spacewalk-koan')); 

show errors
-- $Log$
-- Revision 1  2008/12/04 6:38 pkilambi
-- Added support to create boot image... 

