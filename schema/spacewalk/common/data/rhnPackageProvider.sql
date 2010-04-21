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

insert into rhnPackageProvider (id, name) values
(rhn_package_provider_id_seq.nextval, 'Red Hat Inc.' );
insert into rhnPackageProvider (id, name) values
(rhn_package_provider_id_seq.nextval, 'Fedora' );
insert into rhnPackageProvider (id, name) values
(rhn_package_provider_id_seq.nextval, 'CentOS' );
insert into rhnPackageProvider (id, name) values
(rhn_package_provider_id_seq.nextval, 'Scientific Linux' );
insert into rhnPackageProvider (id, name) values
(rhn_package_provider_id_seq.nextval, 'Suse' );
insert into rhnPackageProvider (id, name) values
(rhn_package_provider_id_seq.nextval, 'Oracle Inc.' );
insert into rhnPackageProvider (id, name) values
(rhn_package_provider_id_seq.nextval, 'Spacewalk' );




commit;

--
-- Revision 1.1  2008/07/02 23:42:28  jsherrill
-- Sequence; data to populate stuff
--

