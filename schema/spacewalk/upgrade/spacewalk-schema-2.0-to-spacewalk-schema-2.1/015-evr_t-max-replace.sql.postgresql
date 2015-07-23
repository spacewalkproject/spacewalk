-- oracle equivalent source sha1 2b426de666bf428ca96c3519882980a8733add57

CREATE OR REPLACE VIEW
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id,
    channel_id
)
AS
select 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 from dual;

create or replace view
rhnChannelNewestPackageView
as
SELECT 1.0 as channel_id,
       1.0 as name_id,
       1.0 as evr_id,
       1.0 as package_arch_id,
       1.0 as package_id from dual;

-- this is the part we actually care about, messing with the views
-- is just a dance to get this to work
drop aggregate if exists max(evr_t);

create aggregate max (
  sfunc=evr_t_larger,
  basetype=evr_t,
  stype=evr_t
);

-- replace the views back to what they actually should be
CREATE OR REPLACE VIEW
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id,
    channel_id
)
AS
SELECT s.org_id,
       sp.server_id,
       x.errata_id,
       up.id,
       up.name_id,
       x.channel_id
    FROM rhnServer s
        join (SELECT sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id, max(sp_pe.evr) AS max_evr
                FROM rhnServerPackage sp_sp
                    join rhnPackageEvr sp_pe ON sp_pe.id = sp_sp.evr_id
                    GROUP BY sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id) sp ON sp.server_id = s.id
        join rhnPackage up ON up.name_id = sp.name_id
        join rhnPackageEvr upe ON upe.id = up.evr_id AND sp.max_evr < upe.evr
        join rhnPackageUpgradeArchCompat puac ON puac.package_arch_id = sp.package_arch_id AND puac.package_upgrade_arch_id = up.package_arch_id
        join rhnServerChannel sc ON sc.server_id = sp.server_id
        join rhnChannelPackage cp ON cp.package_id = up.id AND cp.channel_id = sc.channel_id
        left join
        (SELECT ep.errata_id, cp.channel_id, ep.package_id
         FROM rhnChannelErrata cp
             join rhnErrataPackage ep ON ep.errata_id = cp.errata_id) x
            ON x.channel_id = sc.channel_id AND x.package_id = cp.package_id
;


create or replace view
rhnChannelNewestPackageView
as
SELECT channel_id,
       name_id,
       evr_id,
       package_arch_id,
       max(package_id) as package_id
FROM (
       SELECT m.channel_id          as channel_id,
              p.name_id             as name_id,
              p.evr_id              as evr_id,
              m.package_arch_id     as package_arch_id,
              p.id                  as package_id
         FROM
              (select max(pe.evr) AS max_evr,
                      cp.channel_id,
                      p.name_id,
                      p.package_arch_id
                 from rhnPackageEVR       pe,
                      rhnPackage          p,
                      rhnChannelPackage   cp
                where p.evr_id = pe.id
                  and cp.package_id = p.id
                group by cp.channel_id, p.name_id, p.package_arch_id) m,
              rhnPackageEVR       pe,
              rhnPackage          p,
              rhnChannelPackage   chp
        WHERE m.max_evr = pe.evr
          AND m.name_id = p.name_id
          AND m.package_arch_id = p.package_arch_id
          AND p.evr_id = pe.id
          AND chp.package_id = p.id
          AND chp.channel_id = m.channel_id
) latest_packages
group by channel_id, name_id, evr_id, package_arch_id
;

