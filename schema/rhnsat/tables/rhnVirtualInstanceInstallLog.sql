--
-- $Id$
--


create table
rhnVirtualInstanceInstallLog
(
    id                 number
                           constraint rhn_viil_id_nn not null
                           constraint rhn_viil_id_pk primary key
                           using index tablespace [[64k_tbs]],
    log_message        varchar2(4000)
                           constraint rhn_viil_lm_nn not null,
    ks_session_id      number
                           constraint rhn_viil_ks_sid_fk
                               references rhnKickstartSession(id)
                               on delete cascade,
    created            date default (sysdate)
                           constraint rhn_viil_created_nn not null,
    modified           date default (sysdate)
                           constraint rhn_viil_modified_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create sequence rhn_viil_id_seq;

-- $Log$
