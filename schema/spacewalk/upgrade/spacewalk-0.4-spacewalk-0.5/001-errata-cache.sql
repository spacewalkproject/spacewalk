

drop index rhn_snec_eid_sid_idx;
drop index rhn_snec_sid_eid_idx;
drop index rhn_snec_oid_eid_sid_idx;
drop table rhnServerNeededErrataCache;


/* Remove org id, we don't need it */
ALTER TABLE rhnServerNeededPackageCache DROP CONSTRAINT rhn_sncp_oid_nn;
ALTER TABLE rhnServerNeededPackageCache DROP CONSTRAINT rhn_sncp_oid_fk;
drop index rhn_snpc_oid_idx;
alter table  rhnServerNeededPackageCache drop column  org_id;

/* drop old indexes */
drop index rhn_snpc_pid_idx;
drop index rhn_snpc_sid_idx;
drop index rhn_snpc_eid_idx;


/* rename table */
alter table
   rhnServerNeededPackageCache
  rename to
   rhnServerNeededCache;


/*create new indexes */
create index rhn_snc_pid_idx
        on rhnServerNeededCache(package_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;

create index rhn_snc_sid_idx
        on rhnServerNeededCache(server_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;

create index rhn_snc_eid_idx
        on rhnServerNeededCache(errata_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;


create index rhn_snc_speid_idx
        on rhnServerNeededCache(server_id, package_id, errata_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;



create or replace view
rhnServerNeededPackageCache
(
    server_id,
    package_id,
    errata_id
)
as
select
        server_id, 
        package_id,
        max(errata_id) as errata_id
        from rhnServerNeededCache 
        group by server_id, package_id;


create or replace view
rhnServerNeededErrataCache
(
    server_id,
    errata_id
)
as
select
   distinct  server_id, errata_id
   from rhnServerNeededCache;



CREATE OR REPLACE PROCEDURE
queue_server(server_id_in IN NUMBER, immediate_in IN NUMBER := 1)
IS
    org_id_tmp NUMBER;
BEGIN
    IF immediate_in > 0
    THEN
        DELETE FROM rhnServerNeededCache WHERE server_id = server_id_in;
        INSERT INTO rhnServerNeededCache
            (SELECT server_id, errata_id, package_id
               FROM rhnServerNeededView
              WHERE server_id = server_id_in);

    ELSE
          SELECT org_id INTO org_id_tmp FROM rhnServer WHERE id = server_id_in;

          INSERT
            INTO rhnTaskQueue
                 (org_id, task_name, task_data)
          VALUES (org_id_tmp,
                  'update_server_errata_cache',
                  server_id_in);
    END IF;
END queue_server;




CREATE OR REPLACE VIEW
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id
)
AS
SELECT   distinct  S.org_id,
         S.id,
         PE.errata_id,
         P.id,
         P.name_id
FROM
         rhnPackage P,
         rhnServerPackageArchCompat SPAC,
         rhnPackageEVR P_EVR,
         rhnPackageEVR SP_EVR,
         rhnServerPackage SP,
         rhnChannelPackage CP,
         rhnServerChannel SC,
         rhnServer S,
         rhnErrataPackage PE,
         rhnChannelErrata EC
WHERE
         SC.server_id = S.id
  AND    SC.channel_id = CP.channel_id
  AND    CP.package_id = P.id
  AND    PE.package_id = P.id (+)
  AND    PE.errata_id = EC.errata_id (+)
  AND    EC.channel_id = SC.channel_id (+)
  AND    p.package_arch_id = spac.package_arch_id
  AND    spac.server_arch_id = s.server_arch_id
  AND    SP_EVR.id = SP.evr_id
  AND    P_EVR.id = P.evr_id
  AND    SP.server_id = S.id
  AND    SP.name_id = P.name_id
  AND    SP.evr_id != P.evr_id
  AND    SP_EVR.evr < P_EVR.evr
  AND    SP_EVR.evr = (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND SP2.name_id = SP.name_id)



/
