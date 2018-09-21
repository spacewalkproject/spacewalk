insert into rhnKSInstallType (id, label, name) (
        select sequence_nextval('rhn_ksinstalltype_id_seq'),
               'rhel_8','Red Hat Enterprise Linux 8'
          from dual
         where not exists (select 1 from rhnKSInstallType where  label = 'rhel_8')
        );
