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
-- data for rhnPackageSense

insert into rhnPackageSense(id, label) values (       0,'RPMSENSE_ANY');
insert into rhnPackageSense(id, label) values (       1,'RPMSENSE_SERIAL');
insert into rhnPackageSense(id, label) values (       2,'RPMSENSE_LESS');
insert into rhnPackageSense(id, label) values (       4,'RPMSENSE_GREATER');
insert into rhnPackageSense(id, label) values (       8,'RPMSENSE_EQUAL');
insert into rhnPackageSense(id, label) values (      16,'RPMSENSE_PROVIDES');
insert into rhnPackageSense(id, label) values (      32,'RPMSENSE_CONFLICTS');
insert into rhnPackageSense(id, label) values (      64,'RPMSENSE_PREREQ');
insert into rhnPackageSense(id, label) values (     128,'RPMSENSE_OBSOLETES');
insert into rhnPackageSense(id, label) values (     256,'RPMSENSE_INTERP');
insert into rhnPackageSense(id, label) values (     512,'RPMSENSE_SCRIPT_PRE');
insert into rhnPackageSense(id, label) values (    1024,'RPMSENSE_SCRIPT_POST');
insert into rhnPackageSense(id, label) values (    2048,'RPMSENSE_SCRIPT_PREUN');
insert into rhnPackageSense(id, label) values (    4096,'RPMSENSE_SCRIPT_POSTUN');
insert into rhnPackageSense(id, label) values (    8192,'RPMSENSE_SCRIPT_VERIFY');
insert into rhnPackageSense(id, label) values (   16384,'RPMSENSE_FIND_REQUIRES');
insert into rhnPackageSense(id, label) values (   32768,'RPMSENSE_FIND_PROVIDES');
insert into rhnPackageSense(id, label) values (   65536,'RPMSENSE_TRIGGERIN');
insert into rhnPackageSense(id, label) values (  131072,'RPMSENSE_TRIGGERUN');
insert into rhnPackageSense(id, label) values (  262144,'RPMSENSE_TRIGGERPOSTUN');
insert into rhnPackageSense(id, label) values (  524288,'RPMSENSE_MULTILIB');
insert into rhnPackageSense(id, label) values ( 1048576,'RPMSENSE_SCRIPT_PREP');
insert into rhnPackageSense(id, label) values ( 2097152,'RPMSENSE_SCRIPT_BUILD');
insert into rhnPackageSense(id, label) values ( 4194304,'RPMSENSE_SCRIPT_INSTALL');
insert into rhnPackageSense(id, label) values ( 8388608,'RPMSENSE_SCRIPT_CLEAN');
insert into rhnPackageSense(id, label) values (16777216,'RPMSENSE_RPMLIB');
insert into rhnPackageSense(id, label) values (33554432,'RPMSENSE_TRIGGERPREIN');

--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
