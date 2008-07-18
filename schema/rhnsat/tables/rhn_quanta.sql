--
--$Id$
--
--

--reference table
--quanta current prod row count = 13
create table 
rhn_quanta
(
    quantum_id          varchar2 (10)
        constraint rhn_qnta0_quantum_id_nn not null
        constraint rhn_qnta0_quantum_id_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )

            initrans 32,
    basic_unit_id       varchar2 (20),
    description         varchar2 (200),
    last_update_user    varchar2 (40),
    last_update_date    date
) 
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_quanta 
    is 'qnta0  quanta definitions';

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
