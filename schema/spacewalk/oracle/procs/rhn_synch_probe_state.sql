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
---
--
--
--

--originally from the nolog instance
CREATE OR REPLACE PROCEDURE rhn_synch_probe_state
is
begin
    update
        rhn_probe_state
    set state = 'PENDING',
        output = 'Awaiting update'
    where last_check < (
        select (
            sysdate - greatest(15 / 60 / 24,
            ((3 * rhn_deployed_probe.check_interval_minutes) / 60 / 24)))
        from rhn_deployed_probe
        where rhn_deployed_probe.recid = rhn_probe_state.probe_id
    );
    update rhn_multi_scout_threshold t
    set (scout_warning_threshold, scout_critical_threshold)=(
        select
            decode(scout_warning_threshold_is_all,0,
                scout_warning_threshold,count(scout_id)),
            decode(scout_crit_threshold_is_all,0,
                scout_critical_threshold,count(scout_id))
        from rhn_probe_state p
        where t.probe_id=p.probe_id
          and state in ('OK', 'WARNING', 'CRITICAL')
        group by t.probe_id
    );
end rhn_synch_probe_state;
/
show errors;

--
--Revision 1.5  2004/06/03 20:19:54  pjones
--bugzilla: none -- use procedure names after "end".
--
--Revision 1.4  2004/05/28 22:06:04  pjones
--bugzilla: none -- refer to the right name
--
--Revision 1.3  2004/05/10 20:57:44  kja
--Correcting case of data for rhn_synch_probe_state.  Fixed comment for
--rhn_current_state_summaries.
--
--Revision 1.2  2004/05/10 17:25:08  kja
--Fixing syntax things with the stored procs.
--
--Revision 1.1  2004/04/21 20:47:41  kja
--Added the npcfdb stored procedures.  Renamed the nolog procs to rhn_.
--
--Revision 1.1  2004/04/21 20:09:51  kja
--Added nolog stored procedures.
--
