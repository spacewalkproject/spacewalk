create or replace trigger rhn_checksum_mod_trig
before insert or update on rhnChecksum
for each row
begin
    if :new.id is null then
        select rhnChecksum_seq.nextval into :new.id from dual;
    end if;
end;
/
show errors
