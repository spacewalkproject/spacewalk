insert into rhnCpuArch (id, label, name) (
    select rhn_cpu_arch_id_seq.nextval,
           'sun4v',
           'sun4v'
    from dual
    where not exists (
        select label, name
        from rhnCpuArch
        where label = 'sun4v' and
              name = 'sun4v')
);
