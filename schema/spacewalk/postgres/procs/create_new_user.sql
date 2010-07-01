--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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
--
--

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
        (id, org_id, login, login_uc, password, old_password, oracle_contact_id)
    values
        (user_id_tmp, org_id_in, login_in, upper(login_in), password_in, null, oracle_contact_id_in::numeric);

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


