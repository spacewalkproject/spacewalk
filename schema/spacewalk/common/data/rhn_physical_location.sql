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

--data for rhn_physical_location (uses sequence!!!)

insert into rhn_physical_location(recid, location_name, last_update_user, last_update_date)
    values (rhn_physical_loc_recid_seq.nextval, 'Generic All-Encompassing Location','system', sysdate); 

commit;

--
--Revision 1.1  2004/06/22 02:35:10  kja
--bugzilla 126462 -- create dummy physical_location data
--
