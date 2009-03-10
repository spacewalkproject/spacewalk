create or replace function
lookup_erratafile_type_autonomous (
        label_in in varchar
) returns numeric as
$$
declare
        erratafile_type_id numeric;
begin
        select  id
        into    erratafile_type_id
        from    rhnErrataFileType
        where   label = label_in;

	if not found then
		perform rhn_exception.raise_exception('erratafile_type_not_found');
	end if;

        return erratafile_type_id;
                
end;
$$ language plpgsql stable;
