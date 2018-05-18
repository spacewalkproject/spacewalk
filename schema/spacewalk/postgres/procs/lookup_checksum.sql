-- oracle equivalent source sha1 b6d4a193914ddf50f627abc6f7928aa721c8561a
--
-- Copyright (c) 2010 - 2012 Red Hat, Inc.
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

create or replace function
lookup_checksum(checksum_type_in in varchar, checksum_in in varchar)
returns numeric
as
$$
declare
    checksum_id     numeric;
begin
    if checksum_in is null then
        return null;
    end if;

    select c.id
      into checksum_id
      from rhnChecksumView c
     where c.checksum = checksum_in and
           c.checksum_type = checksum_type_in;

    if not found then
        checksum_id := nextval('rhnchecksum_seq');

        insert into rhnChecksum (id, checksum_type_id, checksum)
          values (
              checksum_id,
              (select id from rhnChecksumType where label = checksum_type_in),
              checksum_in
          )
          on conflict do nothing;

          select c.id
              into strict checksum_id
              from rhnChecksumView c
              where c.checksum = checksum_in and
                  c.checksum_type = checksum_type_in;
    end if;

    return checksum_id;
end;
$$ language plpgsql;

-- NOTE: This is intentionally not thread safe! You must lock rhnChecksum
-- if you are going to use this procedure!
create or replace function
lookup_checksum_fast(checksum_type_in in varchar, checksum_in in varchar)
returns numeric
as
$$
declare
    checksum_id     numeric;
begin
    if checksum_in is null then
        return null;
    end if;

    select c.id
      into checksum_id
      from rhnChecksumView c
     where c.checksum = checksum_in and
           c.checksum_type = checksum_type_in;

    if not found then
        checksum_id := nextval('rhnchecksum_seq');
        insert into rhnChecksum (id, checksum_type_id, checksum) values (
            checksum_id,
            (select id from rhnChecksumType where label = checksum_type_in),
            checksum_in);
    end if;

    return checksum_id;
end;
$$
language plpgsql;
