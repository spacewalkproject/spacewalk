--
-- Copyright (c) 2012 Red Hat, Inc.
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

create or replace function insert_checksum(checksum_in in varchar2, checksum_type_in in varchar2)
return number
is
    checksum_id number;
    pragma autonomous_transaction;
begin
    insert into rhnChecksum (id, checksum_type_id, checksum)
    values (rhnChecksum_seq.nextval,
            (select id from rhnChecksumType where label = checksum_type_in),
             checksum_in) returning id into checksum_id;
    commit;
    return checksum_id;
end;
/
