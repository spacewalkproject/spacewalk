--
--$Id$
--
--

--command_queue_instances_bk current prod row count = 21565
create table 
rhn_command_queue_instances_bk
(
    recid               number   (12)
        constraint rhn_cqinsbk_recid_nn not null,
    command_id          number   (12)
        constraint rhn_cqinsbk_command_id_nn not null,
    notes               varchar2 (2000),
    date_submitted      date
        constraint rhn_cqinsbk_date_sub_nn not null,
    expiration_date     date
        constraint rhn_cqinsbk_exp_date_nn not null,
    notify_email        varchar2 (50),
    timeout             number   (5),
    last_update_user    varchar2 (40),
    last_update_date    date
)
    storage ( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

--$Log$
--Revision 1.2  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
