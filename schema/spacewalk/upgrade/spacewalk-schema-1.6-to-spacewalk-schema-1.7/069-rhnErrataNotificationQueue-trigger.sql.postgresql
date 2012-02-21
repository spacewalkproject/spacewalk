-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

drop trigger rhn_enqueue_mod_trig on rhnErrataKeywordTmp;

create trigger
rhn_enqueue_mod_trig
before insert or update on rhnErrataNotificationQueue
for each row
execute procedure rhn_enqueue_mod_trig_fun();
