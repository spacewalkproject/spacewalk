-- oracle equivalent source sha1 b40d39125bc364ff8e1f42a5ba7f269d87fbeafe

create or replace function rhn_cont_source_ssl_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;


create trigger
rhn_cont_source_ssl_mod_trig
before insert or update on rhnContentSourceSsl
for each row
execute procedure rhn_cont_source_ssl_mod_trig_fun();

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
