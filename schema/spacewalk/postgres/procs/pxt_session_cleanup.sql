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
--
--
--


create or replace function pxt_session_cleanup_autonomous
   (bound_in in numeric, commit_interval in numeric ,
batch_size in numeric , sessions_deleted in numeric)

returns numeric
as
$$
declare
   
   sessions cursor (bound_val  numeric) for
   select rowid from PXTSessions
   where expires < bound_val;

   counter numeric := 0;

   sessions_curs_rowid numeric;

   sessions_deleted_tmp numeric :=0;
   commit_interval_tmp numeric := 100;
   batch_size_tmp numeric := 50000;
   

begin

   open sessions(bound_in);

   loop
	fetch sessions into sessions_curs_rowid;
	exit when not found;

	delete from PXTSessions where rowid = sessions_curs_rowid;

       counter := counter + 1;
       if mod(counter, commit_interval_tmp) = 0 then
          commit;
       end if;

      if counter >= batch_size_tmp then
         commit;
         sessions_deleted_tmp := counter;

         return sessions_deleted_tmp;
      end if;
	
   end loop;
   
   --sessions_deleted := counter;
	
   return counter;

end;
$$
language plpgsql;


CREATE OR REPLACE FUNCTION pxt_session_cleanup(bound_in in numeric, commit_interval in numeric ,
batch_size in numeric , sessions_deleted in numeric)
RETURNS NUMERIC
AS
$$
DECLARE
        ret_val numeric;
BEGIN
        SELECT rectcode into ret_val from dblink('dbname='||current_database(),
        'SELECT pxt_session_cleanup_autonomous('
        ||COALESCE(bound_in::numeric,'null')||','
        ||COALESCE(commit_interval::numeric,'null')||','
        ||COALESCE(batch_size::numeric,'null')||
        ||COALESCE(sessions_deleted::numeric,'null')||')')
        as f (retcode numeric);


        return ret_val;
END;
$$ LANGUAGE PLPGSQL;


