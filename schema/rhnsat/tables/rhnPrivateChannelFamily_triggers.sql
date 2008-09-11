--
-- $Id$
--

create or replace trigger
rhn_privcf_mod_trig
before insert or update on rhnPrivateChannelFamily
for each row
begin
    :new.modified := sysdate;
end;
/
show errors;

