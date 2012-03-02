-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_PACKAGE_NEVRA" (
    name_id_in in varchar2,
    evr_id_in in varchar2,
    package_arch_id_in in varchar2
) return number
is
    pragma autonomous_transaction;
    nevra_id number;
begin
    insert into rhnPackageNEVRA(id, name_id, evr_id, package_arch_id) values
        (rhn_pkgnevra_id_seq.nextval,
         name_id_in,
         evr_id_in,
         package_arch_id_in) returning id into nevra_id;
    commit;
    return nevra_id;
end;
 
/
