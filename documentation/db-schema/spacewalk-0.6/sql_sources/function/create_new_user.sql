-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."CREATE_NEW_USER" 
(
    org_id_in		in number,
    login_in		in varchar2,
    password_in		in varchar2,
    oracle_contact_id_in in number,
    prefix_in		in varchar2,
    first_names_in	in varchar2,
    last_name_in	in varchar2,
    genqual_in		in varchar2,
    parent_company_in	in varchar2,
    company_in		in varchar2,
    title_in		in varchar2,
    phone_in		in varchar2,
    fax_in		in varchar2,
    email_in		in varchar2,
    pin_in		in varchar2,
    first_names_ol_in	in varchar2,
    last_name_ol_in	in varchar2,
    address1_in		in varchar2,
    address2_in		in varchar2,
    address3_in		in varchar2,
    city_in		in varchar2,
    state_in		in varchar2,
    zip_in		in varchar2,
    country_in		in varchar2,
    alt_first_names_in  in varchar2,
    alt_last_name_in    in varchar2,
    contact_call_in	varchar2 := 'N',
    contact_mail_in	varchar2 := 'N',
    contact_email_in	varchar2 := 'N',
    contact_fax_in	varchar2 := 'N'
)
return number
is
    user_id		number;
begin
    select web_contact_id_seq.nextval into user_id from dual;

    insert into web_contact
        (id, org_id, login, login_uc, password, old_password, oracle_contact_id)
    values
        (user_id, org_id_in, login_in, upper(login_in), password_in, null, oracle_contact_id_in);

    insert into web_user_contact_permission
        (web_user_id, call, mail, email, fax)
    values
        (user_id, contact_call_in, contact_mail_in, contact_email_in, contact_fax_in);

    insert into web_user_personal_info
        (web_user_id, prefix, first_names, last_name, genqual,
	parent_company, company, title, phone, fax, email, pin,
	first_names_ol, last_name_ol)
    values
        (user_id, prefix_in, first_names_in, last_name_in, genqual_in,
	parent_company_in, company_in, title_in, phone_in, fax_in, email_in, pin_in,
	first_names_ol_in, last_name_ol_in);

    if address1_in != '.' then
        insert into web_user_site_info
	    (id, web_user_id, email,
	    address1, address2, address3,
	    city, state, zip, country, phone, fax, type,
	    alt_first_names, alt_last_name)
	values
	    (web_user_site_info_id_seq.nextval, user_id, email_in,
	    address1_in, address2_in, address3_in,
	    city_in, state_in, zip_in, country_in, phone_in, fax_in, 'M',
	    alt_first_names_in, alt_last_name_in);
    end if;

    insert into rhnUserInfo
        (user_id)
    values
        (user_id);

    return user_id;
end;
 
/
