-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."CHANNEL_NAME_JOIN" (sep_in in varchar2, ch_in in channel_name_t)
return varchar2
deterministic
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
