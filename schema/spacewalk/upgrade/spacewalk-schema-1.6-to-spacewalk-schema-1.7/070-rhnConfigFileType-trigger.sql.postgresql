-- oracle equivalent source sha1 37fa8dc882a9f6db19a164b1b255b6971205d7c8

drop trigger rhn_conffiletype_mod_trig on rhnConfigFile;

create trigger
rhn_conffiletype_mod_trig
before insert or update on rhnConfigFileType
for each row
execute procedure rhn_conffiletype_mod_trig_fun();
