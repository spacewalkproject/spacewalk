--
-- $Id$
--

create or replace function
channel_name_join(sep_in in varchar2, ch_in in channel_name_t)
return varchar2
is
	ret	varchar2(4000);
	i	binary_integer;
begin
	ret := '';
	i := ch_in.first;

	if i is null
	then
		return ret;
	end if;

	ret := ch_in(i);
	i := ch_in.next(i);

	while i is not null
	loop
		ret := ret || sep_in || ch_in(i);
		i := ch_in.next(i);
	end loop;

	return ret;
end;
/

-- $Log$
-- Revision 1.3  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
