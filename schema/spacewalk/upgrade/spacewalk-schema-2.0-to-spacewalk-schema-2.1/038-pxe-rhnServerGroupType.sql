--  bootstrap_entitled type ----------------------------------------------------

insert into rhnServerGroupType ( id, label, name, permanent, is_base)
   values ( sequence_nextval('rhn_servergroup_type_seq'),
      'bootstrap_entitled', 'Bootstrap Entitled Servers',
      'N', 'Y'
   );

