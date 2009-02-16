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
-- 
--

--data for rhn_threshold_type

insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'warn_min','Minimum',10,'system',sysdate);
insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'warn_max','Maximum',20,'system',sysdate);
insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'crit_min','Minimum',0,'system',sysdate);
insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'crit_max','Maximum',30,'system',sysdate);
commit;

--
--Revision 1.4  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.3  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/22 17:49:49  kja
--Added data for the reference tables.
--
