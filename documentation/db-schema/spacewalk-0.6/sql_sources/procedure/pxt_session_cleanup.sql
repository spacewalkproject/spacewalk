-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."PXT_SESSION_CLEANUP" 
   (bound_in in number, commit_interval in number := 100,
batch_size in number := 50000, sessions_deleted in out number)
is
   PRAGMA AUTONOMOUS_TRANSACTION;

   cursor sessions (bound_val in number) is
   select rowid from PXTSessions
   where expires < bound_val;

   counter number := 0;

begin

   for session in sessions (bound_in) loop

      delete from PXTSessions where rowid = session.rowid;

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
