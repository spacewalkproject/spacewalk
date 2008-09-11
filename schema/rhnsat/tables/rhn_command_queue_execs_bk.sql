--
--$Id$
--
--

--command_queue_execs_bk current prod row count = 75073
create table 
rhn_command_queue_execs_bk
(
    instance_id         number   (12)
        constraint rhn_cqcmdbk_instance_id_nn not null,
    netsaint_id         number   (12)
        constraint rhn_cqcmdbk_netsaint_id_nn not null,
    date_accepted       date,
    date_executed       date,
    exit_status         number   (5),
    execution_time      number   (10),
    stdout              varchar2 (4000),
    stderr              varchar2 (4000),
    last_update_date    date,
    target_type         varchar2 (10)
        constraint rhn_cqcmdbk_target_type_nn not null
)
    storage ( pctincrease 1 freelists 16 )
    initrans 32;

--$Log$
--Revision 1.2  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
