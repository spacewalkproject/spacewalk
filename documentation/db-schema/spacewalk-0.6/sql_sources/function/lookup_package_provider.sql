-- created by Oraschemadoc Mon Aug 31 10:54:42 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."LOOKUP_PACKAGE_PROVIDER" (name_in in varchar2)
return number
is
	package_provider_id number;
begin
	select id into package_provider_id from rhnPackageProvider where name = name_in;
	return package_provider_id;
exception
	when no_data_found then
		rhn_exception.raise_exception('package_provider_not_found');
end;
 
/
