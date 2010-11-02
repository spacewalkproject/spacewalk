-- created by Oraschemadoc Tue Nov  2 08:33:18 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "SPACEWALK"."DELETE_ERRATA" (
	errata_id_in in number
) is
begin
	delete from rhnServerNeededCache where errata_id = errata_id_in;
	delete from rhnErrataFile where errata_id = errata_id_in;
	delete from rhnErrataPackage where errata_id = errata_id_in;
	delete from rhnErrata where id = errata_id_in;
	delete from rhnErrataTmp where id = errata_id_in;
end delete_errata;
 
/
