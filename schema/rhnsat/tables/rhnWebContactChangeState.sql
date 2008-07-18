--
-- $Id$
--
create table rhnWebContactChangeState (
    id                     number
                           constraint rhn_cont_change_state_id_pk primary key,
    label                  varchar2(32)
                           constraint rhn_cont_change_state_nn not null
)
tablespace [[32m_tbs]]
storage( pctincrease 1 freelists 16 )
enable row movement
initrans 32;

create sequence rhn_wcon_change_state_seq;


--
-- $Log$
--
