-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_PACKAGE_DELTA" (n_in in varchar2)
return number
is
    pragma autonomous_transaction;
    name_id     number;
begin
    insert into rhnPackageDelta(id, label)
    values (rhn_packagedelta_id_seq.nextval, n_in) returning id into name_id;
    commit;
    return name_id;
end;
 
/
