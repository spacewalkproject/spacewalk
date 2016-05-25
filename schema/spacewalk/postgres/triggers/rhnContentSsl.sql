-- oracle equivalent source sha1 5be58e5be8899bc47ca97df8daf67949d2f39ef4

create or replace function rhn_cont_ssl_mod_trig_fun() returns trigger as
$$
begin
	new.modified := current_timestamp;
	return new;
end;
$$ language plpgsql;


create trigger
rhn_cont_ssl_mod_trig
before insert or update on rhnContentSsl
for each row
execute procedure rhn_cont_ssl_mod_trig_fun();

create or replace function rhn_cssl_ins_trig_fun() returns trigger as
$$
begin
    if new.id is null then
        new.id := sequence_nextval('rhn_contentssl_seq');
    end if;
    return new;
end;
$$ language plpgsql;

create trigger
rhn_cssl_ins_trig
before insert on rhnContentSsl
for each row
execute procedure rhn_cssl_ins_trig_fun();
