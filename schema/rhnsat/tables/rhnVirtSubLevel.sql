--
-- $Id: $
--

create table rhnVirtSubLevel (
    id      number
            constraint rhn_vsl_id_pk primary key,
    label   varchar2(32)
            constraint rhn_vsl_label_nn not null,
    name    varchar2(128)
            constraint rhn_vsl_name_nn not null,
    created date default sysdate
            constraint rhn_vsl_created_nn not null,
    modified date default sysdate
             constraint rhn_vsl_modified_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create sequence rhn_virt_sl_seq;    

create index rhn_vsl_label_id_name_idx
    on rhnVirtSubLevel(label, id, name)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;


