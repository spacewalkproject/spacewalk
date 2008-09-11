-- $Id$

insert into rhnSolarisPatchType (id, name, label)
   values (rhn_solaris_pt_seq.nextval, 'Generic Patch', 'generic');
insert into rhnSolarisPatchType (id, name, label)
   values (rhn_solaris_pt_seq.nextval, 'Kernel Update Patch', 'kernel');
insert into rhnSolarisPatchType (id, name, label)
   values (rhn_solaris_pt_seq.nextval, 'Restricted Patch', 'restricted');
insert into rhnSolarisPatchType (id, name, label)
   values (rhn_solaris_pt_seq.nextval, 'Point Patch', 'point');
insert into rhnSolarisPatchType (id, name, label)
   values (rhn_solaris_pt_seq.nextval, 'Temporary Patch', 'temporary');
insert into rhnSolarisPatchType (id, name, label)
   values (rhn_solaris_pt_seq.nextval, 'Nonstandard Patch', 'nonstandard');

-- $Log$
