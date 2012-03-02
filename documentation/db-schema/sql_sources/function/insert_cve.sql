-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_CVE" (name_in in varchar2)
return number
is
    pragma autonomous_transaction;
    name_id     number;
begin
    insert into rhnCVE (id, name)
    values (rhn_cve_id_seq.nextval, name_in) returning id into name_id;
    commit;
    return name_id;
end;
 
/
