---
--- Add stored procedures for PostgreSQL compatability.
---

CREATE OR REPLACE VIEW
rhnServerOutdatedPackages
(
    server_id,
    package_name_id,
    package_evr_id,    
    package_nvre,
    errata_id,
    errata_advisory
)
AS
SELECT DISTINCT SNPC.server_id,
       P.name_id, 
       P.evr_id, 
       PN.name || '-' || evr_t_as_vre_simple( PE.evr ),
       E.id,
       E.advisory
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnPackage P,
       rhnServerNeededPackageCache SNPC
         left outer join
        rhnErrata E
          on SNPC.errata_id = E.id
 WHERE SNPC.package_id = P.id
   AND P.name_id = PN.id
   AND P.evr_id = PE.id;

create or replace function evr_t_as_vre( a evr_t )
  return varchar2
is
begin
        return a.as_vre;
end;

create or replace function evr_t_as_vre_simple( a evr_t )
  return VARCHAR2
is
begin
    return a.as_vre_simple;
end;

create or replace function sequence_currval( seq_name varchar2 ) return number as
       ret number;
begin
       execute immediate 'select '|| seq_name || '.currval from dual'
               into ret;
       return ret;
end;

create or replace function sequence_nextval( seq_name varchar2 ) return number as
       ret number;
begin
       execute immediate 'select '|| seq_name || '.nextval from dual'
               into ret;
       return ret;
end;




