-- created by Oraschemadoc Fri Mar  2 05:58:02 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNUSERRECEIVENOTIFICATIONS" ("ORG_ID", "USER_ID", "SERVER_ID") AS 
  select wc.org_id, usp.user_id, usp.server_id
    from rhnUserServerPerms usp
    left join rhnWebContactDisabled wcd
        on usp.user_id = wcd.id
    join web_contact wc
        on usp.user_id = wc.id
    join rhnUserInfo ui
        on usp.user_id = ui.user_id
        and ui.email_notify = 1
    join web_user_personal_info upi
        on usp.user_id = upi.web_user_id
        and upi.email is not null
    left join rhnUserServerPrefs uspr
        on uspr.server_id = usp.server_id
        and usp.user_id = uspr.user_id
        and uspr.name = 'receive_notifications'
        and value='0'
    where uspr.server_id is null
    and wcd.id is null
 
/
