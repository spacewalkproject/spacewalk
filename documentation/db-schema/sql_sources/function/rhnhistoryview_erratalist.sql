-- created by Oraschemadoc Fri Jan 22 13:41:04 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."RHNHISTORYVIEW_ERRATALIST" (action_id IN NUMBER, separator IN VARCHAR2 DEFAULT chr(10))
return VARCHAR2
is
    store_var  VARCHAR2(4000);
    store_tmp  VARCHAR2(4000);
    select_sql VARCHAR2(4000);
    trimmed NUMBER;
    cursor errata_cursor(action_id_in IN NUMBER, separator IN VARCHAR2 DEFAULT chr(10))
    is
       select
           'Errata Advisory: ' || e.advisory || separator ||
	   'Errata Synopsis: ' || e.synopsis || separator
       from
           rhnActionErrataUpdate ae, rhnErrata e
       where
           e.id = ae.errata_id
       and ae.action_id = action_id_in;
begin
    store_var := NULL;
    trimmed := 0;
    open errata_cursor(action_id);
    loop
	fetch errata_cursor into store_tmp;
	exit when errata_cursor%NOTFOUND;
	if store_var is NULL then
	   store_var := store_tmp;
	else
	   trimmed := 1;
	   exit when length(store_var) + length(separator) + length(store_tmp) > 3700;
	   store_var := store_var || separator || store_tmp;
	   trimmed := 0;
	end if;
    end loop;
    close errata_cursor;
    if trimmed <> 0 then
        store_var := store_var || separator || '...';
    end if;
    return store_var;
end;
 
/
