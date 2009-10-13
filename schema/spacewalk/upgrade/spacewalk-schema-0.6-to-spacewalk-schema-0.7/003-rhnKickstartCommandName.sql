insert into rhnKickstartCommandName
    select rhn_kscommandname_id_seq.nextval as id,
          'custom_partition' as name,
          'Y' as uses_arguments,
           53 as sort_order, 'N' as required
    from dual
    where NOT EXISTS (select id from rhnKickstartCommandName where name = 'custom_partition');


