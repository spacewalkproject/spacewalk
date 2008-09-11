--
-- $Id$
--

insert into rhnPushClientState (id, label, name)
    values (rhn_pclient_state_id_seq.nextval, 'online', 'online');
insert into rhnPushClientState (id, label, name)
    values (rhn_pclient_state_id_seq.nextval, 'offline', 'offline');

commit;
--
-- $Log$
-- Revision 1.1  2004/10/07 20:07:50  misa
-- Push client table changes
--
