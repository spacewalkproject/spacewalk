-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

create or replace function rhn_ks_session_history_trigger_fun() returns trigger
as
$$
begin
        if tg_op ='INSERT' then
                insert into rhnKickstartSessionHistory (
                                id, kickstart_session_id, action_id, state_id
                        ) values (
                                nextval('rhn_ks_sessionhist_id_seq'),
                                new.id,
                                new.action_id,
                                new.state_id
                        );
        end if;
        if tg_op ='UPDATE' then
          if new.state_id is distinct from old.state_id then
                insert into rhnKickstartSessionHistory (
                                id, kickstart_session_id, action_id, state_id
                        ) values (
                                nextval('rhn_ks_sessionhist_id_seq'),
                                new.id,
                                new.action_id,
                                new.state_id
                        );
          end if;
        end if;
        return new;
end;
$$ language plpgsql;

