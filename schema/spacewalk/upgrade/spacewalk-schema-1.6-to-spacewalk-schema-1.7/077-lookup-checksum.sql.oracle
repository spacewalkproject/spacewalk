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

create or replace function
lookup_checksum(checksum_type_in in varchar2, checksum_in in varchar2)
return number
is
        checksum_id     number;
begin
        if checksum_in is null then
                return null;
        end if;

        select c.id
          into checksum_id
          from rhnChecksumView c
         where c.checksum = checksum_in
           and c.checksum_type = checksum_type_in;

        return checksum_id;
exception when no_data_found then
    begin
        select insert_checksum(checksum_in, checksum_type_in) into checksum_id from dual;
    exception when dup_val_on_index then
        select c.id
          into checksum_id
          from rhnChecksumView c
         where c.checksum = checksum_in
          and c.checksum_type = checksum_type_in;
    end;
    return checksum_id;
end;
/
show errors
