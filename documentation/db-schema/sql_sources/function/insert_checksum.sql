-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_CHECKSUM" (checksum_in in varchar2, checksum_type_in in varchar2)
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
