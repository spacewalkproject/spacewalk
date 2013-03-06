-- oracle equivalent source sha1 0da7154e84cbb5ccc70b2da4d98326b14e3bbf61

create or replace function rhn_csssl_ins_trig_fun() returns trigger as
$$
begin
    if new.id is null then
        new.id := sequence_nextval('rhn_contentsourcessl_seq');
    end if;
    return new;
end;
$$ language plpgsql;

create trigger
rhn_csssl_ins_trig
before insert on rhnContentSourceSsl
for each row
execute procedure rhn_csssl_ins_trig_fun();
