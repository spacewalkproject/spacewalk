
--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--

create or replace trigger 
rhn_current_alerts_mod_trig
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
/
show errors
