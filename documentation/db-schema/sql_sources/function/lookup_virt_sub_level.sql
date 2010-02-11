-- created by Oraschemadoc Fri Jan 22 13:41:04 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_VIRT_SUB_LEVEL" (label_in in varchar2)
return number
deterministic
is
	virt_sub_level_id number;
begin
	select	vsl.id
	into	virt_sub_level_id
	from	rhnVirtSubLevel vsl
	where	vsl.label = label_in;

	return virt_sub_level_id;
exception
        when no_data_found then
            rhn_exception.raise_exception('invalid_virt_sub_level');
end;
 
/
