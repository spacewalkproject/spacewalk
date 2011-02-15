-- created by Oraschemadoc Thu Jan 20 13:58:48 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."EVR_T_AS_VRE" ( a evr_t )
  return varchar2
is
begin
        return a.as_vre;
end;
 
/
