-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

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
