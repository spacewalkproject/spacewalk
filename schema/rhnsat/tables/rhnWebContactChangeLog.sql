--
-- $Id$
--

create table rhnWebContactChangeLog (
    id                     number
                           constraint rhn_wcon_cl_id_pk primary key,
    web_contact_id         number
                           constraint rhn_wcon_cl_wcon_id_nn not null
                           constraint rhn_wcon_cl_wcon_id_fk references web_contact(id)
                           on delete cascade,
    web_contact_from_id    number
                           constraint rhn_wcon_cl_wcon_from_id_fk references web_contact(id)
                           on delete set null,
    change_state_id        number
                           constraint rhn_wcon_cl_change_sid_nn not null
                           constraint rhn_wcon_cl_csid_fk references rhnWebContactChangeState(id),
    date_completed         date default(sysdate)
                           constraint rhn_wcon_cl_modified_nn not null
)
storage( pctincrease 1 freelists 16 )
enable row movement
initrans 32;

create sequence rhn_wcon_disabled_seq;

create index rhn_wcon_disabled_wcon_id_idx
       on rhnWebContactChangeLog(web_contact_id)
       storage (pctincrease 1 freelists 16)
       initrans 32
       nologging;

--
-- $Log$
--
