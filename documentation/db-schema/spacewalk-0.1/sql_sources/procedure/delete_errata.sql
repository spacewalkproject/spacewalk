-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "RHNSAT"."DELETE_ERRATA" (
	errata_id_in in number
) is
begin
	delete from rhnServerNeededPackageCache where errata_id = errata_id_in;
	delete from rhnPaidErrataTempCache where errata_id = errata_id_in;
	delete from rhnErrataFile where errata_id = errata_id_in;
	delete from rhnErrataPackage where errata_id = errata_id_in;
	delete from rhnErrata where id = errata_id_in;
	delete from rhnErrataTmp where id = errata_id_in;
end delete_errata;
 
/
