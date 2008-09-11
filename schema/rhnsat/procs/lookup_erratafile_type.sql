--
-- $Id$
--

create or replace function
lookup_erratafile_type (
	label_in in varchar2
) return number deterministic is
	pragma autonomous_transaction;
	erratafile_type_id number;
begin
	select	id
	into	erratafile_type_id
	from	rhnErrataFileType
	where	label = label_in;

	return erratafile_type_id;
exception
	when no_data_found then
		rhn_exception.raise_exception('erratafile_type_not_found');
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/03/11 00:37:16  pjones
-- bugzilla: 85516
--
-- public errata schema checkin
--
-- bretm, you owe me cookies.
--
