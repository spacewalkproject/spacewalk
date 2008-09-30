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

--data for rhn_command_requirements

insert into rhn_command_requirements(name,description) 
    values (
'npunix','RHNMD must be running on the monitored host to perform this check.');

insert into rhn_command_requirements(name,description) 
    values (
'oracle','Oracle checks require the configuration of the database and public associations made by running $ORACLE_HOME/rdbms/admin/catalog.sql. In addition, in any instance of Oracle, the Oracle user configured in the check must have minimum privileges of CONNECT and SELECT_CATALOG_ROLE.');

insert into rhn_command_requirements(name,description) 
    values (
'snmp','SNMP must be running on the monitored host to perform this check.');

insert into rhn_command_requirements(name,description) 
    values (
'bea61_snmp','This check may be configured against a BEA Managed Server if the IP address of the Domain Admin Server is given.SNMP must also be enabled on the Domain Admin Server which can be done via the Weblogic Console.');

insert into rhn_command_requirements(name,description) 
    values (
'npunix_oracle','RHNMD must be running on the monitored host to perform this check. Oracle checks require the configuration of the database and public associations made by running $ORACLE_HOME/rdbms/admin/catalog.sql. In addition, in any instance of Oracle, the Oracle user configured in the check must have minimum privileges of CONNECT and SELECT_CATALOG_ROLE.');

insert into rhn_command_requirements(name,description) 
    values (
'apache1_3','The ExtendedStatus directive in the httpd.conf file of this webserver must be set to On for this check to function properly.');

commit;

--
--Revision 1.7  2004/06/22 18:01:26  nhansen
--bug 126498: replace Command Center Daemon refrences with RHNMD
--
--Revision 1.6  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.5  2004/06/09 19:10:36  nhansen
--bug 124620: put the commit back
--
--Revision 1.4  2004/06/09 17:35:36  nhansen
--bug 124620: pulled out unused command_requirements data that won't be used for rhn monitoring
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
