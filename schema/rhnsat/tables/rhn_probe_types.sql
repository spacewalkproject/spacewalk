--
--$Id$
--
--

--reference table
--probe_types current prod row count = 7
create table 
rhn_probe_types
(
    probe_type          varchar2 (20)
        constraint rhn_prbtp_probe_type_nn not null
        constraint rhn_prbtp_probe_type_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    type_description    varchar2 (200)
        constraint rhn_prbtp_type_desc_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_probe_types 
    is 'prbtp  probe types';

--$Log$
--Revision 1.3  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
