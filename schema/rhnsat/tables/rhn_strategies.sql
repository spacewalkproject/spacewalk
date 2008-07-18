--
--$Id$
--
--

--reference table
--strategies current prod row count = 6
create table 
rhn_strategies
(
    recid               number   (12)
        constraint rhn_strat_recid_nn not null
        constraint rhn_strat_recid_ck check (recid > 0)
        constraint rhn_strat_recid_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    name                varchar2 (80),
    comp_crit           varchar2 (80),
    esc_crit            varchar2 (80),
    contact_strategy    varchar2 (32)
        constraint rhn_strat_cont_strat_ck 
            check (contact_strategy in ('Broadcast','Escalate')),
    ack_completed       varchar2 (32)
        constraint rhn_strat_ack_comp_ck 
            check (ack_completed in ( 'All', 'One','No' ))
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_strategies 
    is 'strat  strategy definitions';

create sequence rhn_strategies_recid_seq;

--$Log$
--Revision 1.4  2004/05/26 21:43:20  kja
--Fix constraints for proper capitalization.
--
--Revision 1.3  2004/05/19 02:16:25  kja
--Fixed syntax issues.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 19:51:58  kja
--More monitoring schema.
--
