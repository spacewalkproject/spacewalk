-- created by Oraschemadoc Thu Jan 20 13:58:56 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_ERRATAFILE_TYPE" (
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
