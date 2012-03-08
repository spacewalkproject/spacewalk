--
-- Copyright (c) 2008-2012 Red Hat, Inc.
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

create or replace procedure pxt_session_cleanup (
    bound_in in number,
    commit_interval in number := 100,
    batch_size in number := 50000,
    sessions_deleted in out number)
is
    cursor sessions (bound_val in number) is
        select rowid
          from pxtsessions
         where expires < bound_val;

    counter number := 0;
begin
   for session in sessions (bound_in) loop
       delete
         from pxtsessions
        where rowid = session.rowid;
      
       counter := counter + 1;
       if mod(counter, commit_interval) = 0 then
           commit;
       end if;

       if counter >= batch_size then
           commit;
           sessions_deleted := counter;
           return;
       end if;
    end loop;

    commit;
    sessions_deleted := counter;
end;
/
