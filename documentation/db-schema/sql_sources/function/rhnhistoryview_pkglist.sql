-- created by Oraschemadoc Fri Jan 22 13:41:04 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."RHNHISTORYVIEW_PKGLIST" (action_id IN NUMBER, separator IN VARCHAR2 DEFAULT chr(10))
return VARCHAR2
is
    store_var  VARCHAR2(4000);
    store_tmp  VARCHAR2(4000);
    select_sql VARCHAR2(4000);
    trimmed NUMBER;
    cursor pkg_cursor(action_id_in IN NUMBER)
    is
       select
           pn.name||'-'||pevr.version||'-'||pevr.release||'.'||pa.name
       from
           rhnPackageName pn, rhnPackageEVR pevr, rhnPackageArch pa,
	   rhnActionPackage ap
       where
               ap.name_id = pn.id
	   and ap.evr_id = pevr.id
	   and ap.package_arch_id = pa.id(+)
	   and ap.action_id = action_id_in;
begin
    store_var := NULL;
    trimmed := 0;
    open pkg_cursor(action_id);
    loop
	fetch pkg_cursor into store_tmp;
	exit when pkg_cursor%NOTFOUND;
	if store_var is NULL then
	   store_var := store_tmp;
	else
	   trimmed := 1;
	   exit when length(store_var) + length(separator) + length(store_tmp) > 3700;
	   store_var := store_var || separator || store_tmp;
	   trimmed := 0;
	end if;
    end loop;
    close pkg_cursor;
    if trimmed <> 0 then
        store_var := store_var || separator || '...';
    end if;
    return store_var;
end;
 
/
