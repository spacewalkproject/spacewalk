select distinct
        'alter table '||dc.owner||'.'||dc.table_name,
        '       drop constraint '||dc.constraint_name||';',
        'alter table '||dc.owner||'.'||dc.table_name,
        '       add constraint '||dc.constraint_name,
        '       foreign key ('||dcc.column_name||
        ') references '||'rhn.rhnPackageObj(id);'
from
        all_constraints dc,
        all_constraints ref_dc,
        all_cons_columns dcc,
        all_cons_columns ref_dcc
where
            ref_dc.table_name = 'RHNPACKAGE'
        and ref_dcc.column_name = 'ID'
        and dc.constraint_type = 'R'
        and dc.r_owner = ref_dc.owner
        and dc.r_constraint_name = ref_dc.constraint_name
        and dc.owner = dcc.owner
        and dc.constraint_name = dcc.constraint_name
        and ref_dc.owner = ref_dcc.owner
        and ref_dc.constraint_name = ref_dcc.constraint_name
/
