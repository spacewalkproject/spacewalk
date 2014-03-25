-- oracle equivalent source sha1 62e88a9515ca6f596c142f071aeda5d786d857a8

alter table web_contact_log drop column old_password;

alter table web_contact_log alter password type varchar(110);

select logging.recreate_trigger('web_contact');
