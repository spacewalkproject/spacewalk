-- $Id$

create table rhnSolarisPatchType (
   id          number
               constraint rhn_solaris_pt_pk primary key,
   name        varchar2(32)
               constraint rhn_solaris_pt_name_nn not null,
   label       varchar2(32)
               constraint rhn_solaris_pt_label_nn not null
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
initrans 32;

create sequence rhn_solaris_pt_seq;

-- $Log$
