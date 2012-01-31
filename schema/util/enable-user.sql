insert into rhnWebContactChangeLog 
(id, web_contact_id, web_contact_from_id, change_state_id, date_completed)
values
(sequence_nextval('rhn_wcon_disabled_seq'),
 (select id from web_contact where login_uc = upper('&login')),
 null,
 (select id from rhnWebContactChangeState where label = 'enabled'),
 sysdate); 
