insert into rhnServerArch (id, label, name, arch_type_id) (
    select rhn_server_arch_id_seq.nextval,
           'sparc-sun4v-solaris',
           'Sparc Solaris',
           lookup_arch_type('sysv-solaris')
    from dual
    where not exists (
        select label, name, arch_type_id
        from rhnServerArch
        where label = 'sparc-sun4v-solaris' and
              name = 'Sparc Solaris' and
              arch_type_id = lookup_arch_type('sysv-solaris'))
);
