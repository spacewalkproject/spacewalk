insert into rhnCpuArch (id, label, name) (
    select rhn_cpu_arch_id_seq.nextval, 'i86pc', 'i86pc'
    from dual
    where not exists (
        select 1
        from rhnCpuArch
        where label = 'i86pc' and name = 'i86pc')
);

