-- data for rhnVirtualInstanceType


insert into rhnVirtualInstanceType (id, name, label)
     values (rhn_vit_id_seq.nextval, 'Fully Virtualized', 'fully_virtualized');

insert into rhnVirtualInstanceType (id, name, label)
     values (rhn_vit_id_seq.nextval, 'Para-Virtualized', 'para_virtualized');

