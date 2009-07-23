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


insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'md5', 'md5sum' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha1', 'sha1' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha-256', 'sha256' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha-384', 'sha384' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha-512', 'sha512' );

commit;

--
--
-- Revision 1.1  2009/06/26 11:00:17  pkilambi
--

