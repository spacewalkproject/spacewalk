-- created by Oraschemadoc Fri Jan 22 13:40:57 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_CURRENT_ALERTS_MOD_TRIG"
before insert or update on rhn_current_alerts
referencing new as new old as old
for each row
declare
msg varchar2(200);
date_completed_is_null exception;
date_completed_is_not_null exception;

begin

    if :new.in_progress=0 and :new.date_completed is null
    then
        --- in_progress and date_completed are being updated simultaneously
        if ( updating( 'in_progress' ) and updating( 'date_completed') )
             or inserting
        then
            raise date_completed_is_null;
        elsif  updating( 'in_progress' )
        ---  date_completed is not being updated - so we can close the alert
        then
            :new.date_completed:=sysdate;
        else
        ---  date_completed is being updated - so we have to reopen alert
            :new.in_progress:=1;
        end if;
    elsif :new.in_progress=1 and :new.date_completed is not null
    then

        if ( updating( 'in_progress' ) and updating( 'date_completed') )
            or inserting
        --- in_progress and date_completed are being updated simultaneously
        then
            raise date_completed_is_not_null;
        elsif  updating( 'in_progress' )
        ---  date_completed is not being updated - so we can reopen the alert
        then
            :new.date_completed:=null;
        else
        ---  date_completed is being updated - so we have to close alert
            :new.in_progress:=0;
        end if;

    end if;

    exception
    when date_completed_is_null then
    msg:='date_completed is null while in_progress=0';
    raise_application_error (-20012,msg);
    when date_completed_is_not_null then
    msg:='date_completed is not null while in_progress=1';
    raise_application_error (-20012,msg);
    when others then
    raise;
end;
ALTER TRIGGER "SPACEWALK"."RHN_CURRENT_ALERTS_MOD_TRIG" ENABLE
 
/
