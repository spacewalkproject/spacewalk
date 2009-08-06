insert into rhnPackageArch (id, label, name, arch_type_id) (
    select rhn_package_arch_id_seq.nextval,
           'sparc.sun4v-solaris',
           'Sparc Solaris sun4v',
           lookup_arch_type('sysv-solaris')
    from dual
    where not exists (
        select id, label, name, arch_type_id
        from rhnPackageArch
        where label = 'sparc.sun4v-solaris' and
              name = 'Sparc Solaris sun4v'and
              arch_type_id = lookup_arch_type('sysv-solaris'))
);
