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
            (rhn_checksum_id_seq.nextval, 'sha1', 'sha1sum' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha224', 'sha224sum' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha256', 'sha256sum' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha384', 'sha384sum' );
insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha512', 'sha512sum' );

commit;

