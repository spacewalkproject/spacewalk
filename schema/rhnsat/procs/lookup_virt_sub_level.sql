--
-- $Id: lookup_sg_type.sql 45110 2004-02-19 22:19:29Z pjones $
--

create or replace function
lookup_virt_sub_level(label_in in varchar2)
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
show errors

--
-- $Log$
-- Revision 1.1  2004/02/19 22:19:29  pjones
-- bugzilla: 115896 -- don't let servers subscribe to services for which
-- their server arch is not compatible
--
