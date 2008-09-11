insert into rhnKSTreeType (id, label, name)
        values (rhn_kstree_type_seq.nextval,
                'rhn-managed','RHN managed kickstart tree'
        );

insert into rhnKSTreeType (id, label, name)
        values (rhn_kstree_type_seq.nextval,
                'externally-managed','Externally managed kickstart tree'
        );

commit;
