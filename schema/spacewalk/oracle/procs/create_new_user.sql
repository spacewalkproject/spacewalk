--
-- Copyright (c) 2008 Red Hat, Inc.
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
show errors

--
-- Revision 1.14  2004/02/06 15:53:12  pjones
-- bugzilla: none -- pretend chip has style
--
-- Revision 1.13  2004/02/05 17:07:44  cturner
-- simplify user creation; skip the site info record if it looks like one of the funny "." records
--
-- Revision 1.12  2003/04/29 15:10:18  pjones
-- make the default values ones that will work (although I think they're
-- never used)
--
-- Revision 1.11  2003/01/14 03:25:31  cturner
-- fix accidental line deletion
--
-- Revision 1.10  2003/01/10 18:08:26  pjones
-- the trigger on wupi will do this insert
--
-- Revision 1.9  2003/01/09 20:08:59  pjones
-- More BEL stuff:
--
-- create_new_user:
--   now adds an rhnUserEmail entry
-- create_new_org
--   now adds an rhnOrgState entry
-- rhn_bel:
--   package for rhn_bel state changes
--
-- Revision 1.8  2002/02/19 17:47:00  pjones
-- use synonym for web_user_contact_permission instead of "web." version,
-- so create_new_user can be the same in satellite
--
-- Revision 1.7  2001/10/15 20:17:27  cturner
-- create user info records
--
-- Revision 1.6  2001/09/25 15:42:50  cturner
-- fixing old broken comment
--
-- Revision 1.5  2001/07/07 16:22:47  cturner
-- three features: fixed the old_password issue when leaving the applicant group; populate alt_*_name on new user creation; unselect all on the view of users and lists
--
-- Revision 1.4  2001/07/02 07:40:38  gafton
-- more formatting for this NIGHTMARE
--
-- Revision 1.3  2001/07/02 07:30:08  gafton
-- attempt to reorganize for readability this sore example for a PL/SQl function
--


