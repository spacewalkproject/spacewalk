-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."CREATE_PXT_SESSION" (web_user_id in number, expires in number, value in varchar)
return number
is
pragma autonomous_transaction;
	id number;
begin
	select
		pxt_id_seq.nextval into id
	from
		dual;

	insert into PXTSessions (id, value, expires, web_user_id)
	values (id, value, expires, web_user_id);
	commit;

	return id;
end;
 
/
