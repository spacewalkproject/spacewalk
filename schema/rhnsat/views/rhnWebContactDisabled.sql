--
-- $Id$
--
create or replace view
rhnWebContactDisabled
as
select
   wcon.id,
   wcon.org_id,
   wcon.login,
   wcon.login_uc,
   wcon.password,
   wcon.old_password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   rhnWebContactChangeLog   wccl,
   rhnWebContactChangeState wccs,
   web_contact              wcon
where 1=1
   and wccl.change_state_id = wccs.id
   and wccs.label = 'disabled'
   and wccl.web_contact_id = wcon.id
   and wccl.date_completed =
              (select max(wccl_exists.date_completed)
                 from rhnWebContactChangeLog   wccl_exists
                where wccl.web_contact_id = wccl_exists.web_contact_id);


--
-- $Log$
--
