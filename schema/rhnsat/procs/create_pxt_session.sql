--
-- $Id$
--

create or replace function
create_pxt_session(web_user_id in number, expires in number, value in varchar)
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
show errors

-- $Log$
-- Revision 1.2  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
