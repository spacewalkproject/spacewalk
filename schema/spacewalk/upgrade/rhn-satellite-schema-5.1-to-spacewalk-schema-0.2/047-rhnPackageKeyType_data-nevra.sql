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
-- $Id$

insert into rhnPackageKeyType (id, label) values
(rhn_package_key_type_id_seq.nextval, 'gpg' );
insert into rhnPackageKeyType (id, label) values
(rhn_package_key_type_id_seq.nextval, 'pgp' );
insert into rhnPackageKeyType (id, label) values
(rhn_package_key_type_id_seq.nextval, 'rsa' );
insert into rhnPackageKeyType (id, label) values
(rhn_package_key_type_id_seq.nextval, 'dsa' );



commit;

-- $Log$
-- Revision 1.1  2008/07/02 23:42:28  jsherrill
-- Sequence; data to populate stuff
--

