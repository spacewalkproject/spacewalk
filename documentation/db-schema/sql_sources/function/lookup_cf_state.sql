-- created by Oraschemadoc Thu Jan 20 13:58:52 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_CF_STATE" (
	label_in in varchar2
) return number deterministic
is
	state_id number;
begin
	select	id
	into	state_id
	from	rhnConfigFileState
	where	label = label_in;

	return state_id;
end;
 
/
