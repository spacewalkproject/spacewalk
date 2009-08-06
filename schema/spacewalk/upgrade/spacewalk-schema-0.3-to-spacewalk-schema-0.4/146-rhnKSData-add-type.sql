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

ALTER TABLE rhnKsData
ADD ks_type varchar(8);

UPDATE rhnKsData SET ks_type = 'wizard';

ALTER TABLE rhnKsData 
MODIFY ks_type CONSTRAINT rhn_ks_type_nn NOT NULL;

ALTER TABLE rhnKsData 
ADD CONSTRAINT rhn_ks_type_ck CHECK (ks_type in ('wizard', 'raw'));

show errors

-- $Log$
-- Revision 2  2008/12/02 16:51:05.2 jsherrill
-- Add cobbler_id column
--
-- Revision 1  2008/10/01 7:01:05  mmccune
-- Removed the unused name column
