-- created by Oraschemadoc Fri Jan 22 13:40:55 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_CMETH_VAL_TRIG"
before insert or update on rhn_contact_methods
referencing new as new old as old
for each row
declare
    msg  varchar2(200);
    missing_data exception;
begin
    msg :='missing or invalid data for contact_methods table';

    if :new.method_type_id = 1
    then

    --- pager fields pager_email,pager_split_long_messages should be not null
        if (
            :new.pager_email   is null     or
            :new.pager_split_long_messages  is null )
        then
            raise missing_data;
        end if;
    end if;

    if :new.method_type_id = 2
    then

    --- the all email fields but email_reply_to should be not null
        if :new.email_address is null
        then
            raise missing_data;
        end if;
    end if;

    if :new.method_type_id = 5
    then

    --- the all sntp fields be not null
        if (:new.snmp_host is null   or
           :new.snmp_port is null)
        then
            raise missing_data;
        end if;
    end if;

    exception
    when missing_data then
    raise_application_error (-20012,msg);
    when others then
    raise;
end;
ALTER TRIGGER "SPACEWALK"."RHN_CMETH_VAL_TRIG" ENABLE
 
/
