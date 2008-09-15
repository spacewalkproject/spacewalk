insert into rhnServerArch (id, label, name, arch_type_id) values
(rhn_server_arch_id_seq.nextval, 'sparc-sun4v-solaris', 'Sparc Solaris', lookup_arch_type('sysv-solaris'));
