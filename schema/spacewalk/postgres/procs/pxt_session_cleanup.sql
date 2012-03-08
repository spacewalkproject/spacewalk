-- oracle equivalent source sha1 8236eb1e649092e2f2659b57778fca6a722a520f
-- retrieved from ./1241128047/984a347f2afbd47756e90584364799dd670b62db/schema/spacewalk/oracle/procs/pxt_session_cleanup.sql
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

--
-- TODO: look closer at usage of this.  Probably we should get rid of the
-- looping and do the delete in a single command.  Oracle's problems with
-- large transactions are not relevant to Postgres.
--

create or replace function pxt_session_cleanup
   (bound_in in numeric, commit_interval in numeric default 100,
    batch_size in numeric default 50000, sessions_deleted in numeric default 0)
returns numeric
as
$$
declare
   sessions cursor (bound_val  numeric) for
   select ctid from PXTSessions
   where expires < bound_val;

   counter numeric := 0;
begin

   for session in sessions (bound_in) loop

      delete from PXTSessions where ctid = session.ctid;
      
       counter := counter + 1;

       -- commit_interval is ignored

      if counter >= batch_size then 
         return counter;
      end if;

   end loop;  

   return counter;
end;
$$
language plpgsql;
