-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "RHNSAT"."CHECK_EMAIL_UNIQUENESS" (
	email_in in varchar2
)
return number
is
	cursor sources(email_cin in varchar2) is
		select	1
		from	web_user_personal_info	wupi
		where	wupi.email = email_cin;
begin
	for source in sources(email_in)
	loop
		return 0;
	end loop;
	return 1;
end;
 
/
