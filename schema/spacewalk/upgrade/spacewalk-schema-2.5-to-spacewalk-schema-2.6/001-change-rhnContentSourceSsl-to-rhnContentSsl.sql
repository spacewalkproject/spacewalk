-- Create new table
create table
rhnContentSsl
(
        id number not null
                constraint rhn_cssl_id_pk primary key,
        content_source_id number
                constraint rhn_cssl_csid_uq unique
                constraint rhn_cssl_csid_fk references rhnContentSource(id) on delete cascade,
        channel_family_id number
                constraint rhn_cssl_cfid_uq unique
                constraint rhn_cssl_cfid_fk references rhnChannelFamily(id) on delete cascade,
        ssl_ca_cert_id number not null
                constraint rhn_cssl_cacertid_fk references rhnCryptoKey(id),
        ssl_client_cert_id number
                constraint rhn_cssl_clcertid_fk references rhnCryptoKey(id),
        ssl_client_key_id number
                constraint rhn_cssl_clkeyid_fk references rhnCryptoKey(id),
        constraint rhn_cssl_client_chk check(ssl_client_key_id is null or ssl_client_cert_id is not null),
        constraint rhn_cssl_type_chk check((content_source_id is null and channel_family_id is not null)
                                        or (content_source_id is not null and channel_family_id is null)),
        created timestamp with local time zone default(current_timestamp) not null,
        modified timestamp with local time zone default(current_timestamp) not null
)
enable row movement
;

create sequence rhn_contentssl_seq;

-- Create dependent triggers

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

-- Copy values
insert into rhnContentSsl (content_source_id, ssl_ca_cert_id, ssl_client_cert_id, ssl_client_key_id)
select content_source_id, ssl_ca_cert_id, ssl_client_cert_id, ssl_client_key_id from rhnContentSourceSsl;

-- Drop old stuff
delete from rhnContentSourceSsl;
drop table rhnContentSourceSsl;
drop function rhn_csssl_ins_trig_fun();
drop function rhn_cont_source_ssl_mod_trig_fun();
drop sequence rhn_contentsourcessl_seq;
