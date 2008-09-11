--
-- $Id$
--
-- triggers for web_user_personal_info

create or replace trigger
web_user_pi_timestamp
BEFORE INSERT OR UPDATE ON web_user_personal_info
FOR EACH ROW
BEGIN
  :new.modified := sysdate;
END;
/
show errors

