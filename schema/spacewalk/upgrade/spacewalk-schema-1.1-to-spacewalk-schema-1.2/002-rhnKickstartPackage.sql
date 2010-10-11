-- first, delete duplicate kickstart_id, package_name_id pairs if any

delete
    from rhnKickstartPackage
   where rowid not in
       (select min(rowid)
          from rhnKickstartPackage
      group by kickstart_id, package_name_id);

commit;

ALTER TABLE rhnKickstartPackage
    ADD CONSTRAINT rhn_kspackage_name_uq UNIQUE (kickstart_id, package_name_id)
    USING INDEX TABLESPACE [[4m_tbs]];
