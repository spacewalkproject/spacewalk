-- oracle equivalent source sha1 427329b9537baf0257349abbc1b296d6f3a3f914

-- ## views

create or replace view
rhnUserReceiveNotifications
as
select
	0::numeric as org_id,
	0::numeric as user_id,
	0::numeric as server_id
from dual;

drop view rhnWebContactEnabled;
drop view rhnWebContactDisabled;

create or replace view
rhnWebContactDisabled
as
select
   wcon.id,
   wcon.org_id,
   wcon.login,
   wcon.login_uc,
   wcon.password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   rhnWebContactChangeLog   wccl,
   rhnWebContactChangeState wccs,
   web_contact              wcon
where wccl.change_state_id = wccs.id
   and wccs.label = 'disabled'
   and wccl.web_contact_id = wcon.id
   and wccl.date_completed =
              (select max(wccl_exists.date_completed)
                 from rhnWebContactChangeLog   wccl_exists
                where wccl.web_contact_id = wccl_exists.web_contact_id);

create or replace view
rhnWebContactEnabled
as
select
   wcon.id,
   wcon.org_id,
   wcon.login,
   wcon.login_uc,
   wcon.password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   web_contact wcon
where not exists (
     select 1 from rhnWebContactDisabled
     where wcon.id = rhnWebContactDisabled.id
   );

create or replace view rhnUserReceiveNotifications
as
    select wc.org_id, usp.user_id, usp.server_id
    from rhnUserServerPerms usp
    left join rhnWebContactDisabled wcd
        on usp.user_id = wcd.id
    join web_contact wc
        on usp.user_id = wc.id
    join rhnUserInfo ui
        on usp.user_id = ui.user_id
        and ui.email_notify = 1
    join web_user_personal_info upi
        on usp.user_id = upi.web_user_id
        and upi.email is not null
    left join rhnUserServerPrefs uspr
        on uspr.server_id = usp.server_id
        and usp.user_id = uspr.user_id
        and uspr.name = 'receive_notifications'
        and value='0'
    where uspr.server_id is null
    and wcd.id is null;

-- ## create_new_user

create or replace function
create_new_user
(
    org_id_in           in numeric,
    login_in            in varchar,
    password_in         in varchar,
    oracle_contact_id_in in varchar,
    prefix_in           in varchar,
    first_names_in      in varchar,
    last_name_in        in varchar,
    genqual_in          in varchar,
    parent_company_in   in varchar,
    company_in          in varchar,
    title_in            in varchar,
    phone_in            in varchar,
    fax_in              in varchar,
    email_in            in varchar,
    pin_in              in numeric,
    first_names_ol_in   in varchar,
    last_name_ol_in     in varchar,
    address1_in         in varchar,
    address2_in         in varchar,
    address3_in         in varchar,
    city_in             in varchar,
    state_in            in varchar,
    zip_in              in varchar,
    country_in          in varchar,
    alt_first_names_in  in varchar,
    alt_last_name_in    in varchar,
    contact_call_in     varchar,
    contact_mail_in     varchar,
    contact_email_in    varchar,
    contact_fax_in      varchar
)
returns numeric
AS
$$
declare
    user_id_tmp             numeric;


    -- Would be using the below variables instead of the last four parameters
    contact_call_in_tmp     varchar := 'N';
    contact_mail_in_tmp     varchar := 'N';
    contact_email_in_tmp    varchar := 'N';
    contact_fax_in_tmp      varchar := 'N';
begin
    select nextval('web_contact_id_seq') into user_id_tmp;

    insert into web_contact
        (id, org_id, login, login_uc, password, oracle_contact_id)
    values
        (user_id_tmp, org_id_in, login_in, upper(login_in), password_in, oracle_contact_id_in::numeric);

    insert into web_user_contact_permission
        (web_user_id, call, mail, email, fax)
    values
        (user_id_tmp, contact_call_in_tmp, contact_mail_in_tmp, contact_email_in_tmp, contact_fax_in_tmp);

    insert into web_user_personal_info
        (web_user_id, prefix, first_names, last_name, genqual,
        parent_company, company, title, phone, fax, email, pin,
        first_names_ol, last_name_ol)
    values
        (user_id_tmp, prefix_in, first_names_in, last_name_in, genqual_in,
        parent_company_in, company_in, title_in, phone_in, fax_in, email_in, pin_in :: numeric,
        first_names_ol_in, last_name_ol_in);

    if address1_in != '.' then
        insert into web_user_site_info
            (id, web_user_id, email,
            address1, address2, address3,
            city, state, zip, country, phone, fax, type,
            alt_first_names, alt_last_name)
        values
            (nextval('web_user_site_info_id_seq'), user_id_tmp, email_in,
            address1_in, address2_in, address3_in,
            city_in, state_in, zip_in, country_in, phone_in, fax_in, 'M',
            alt_first_names_in, alt_last_name_in);
    end if;

    insert into rhnUserInfo
        (user_id)
    values
        (user_id_tmp);

    return user_id_tmp;
end;
$$
language plpgsql;

-- ## web_contact triggers

create or replace function web_contact_upd_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;
        new.login_uc := UPPER(new.login);

        return new;
end;
$$
language plpgsql;

-- ## drop web_contact.old_password

alter table web_contact drop column old_password;
