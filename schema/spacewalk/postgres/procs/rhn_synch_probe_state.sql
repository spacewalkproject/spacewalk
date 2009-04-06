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

CREATE OR REPLACE FUNCTION rhn_synch_probe_state()
RETURNS VOID 
AS
$$
begin
    update
        rhn_probe_state
    set state = 'PENDING',
        output = 'Awaiting update'
    where last_check < (
        select (
            current_timestamp - greatest(15 / 60 / 24,
            ((3 * rhn_deployed_probe.check_interval_minutes) / 60 / 24)))
        from rhn_deployed_probe
        where rhn_deployed_probe.recid = rhn_probe_state.probe_id
    );

    
    update rhn_multi_scout_threshold
    set scout_warning_threshold = (select
            decode(scout_warning_threshold_is_all,0,
                scout_warning_threshold,count(scout_id))
        from rhn_probe_state p, rhn_multi_scout_threshold t
        where t.probe_id=p.probe_id
          and state in ('OK', 'WARNING', 'CRITICAL')
             group by t.probe_id
) , 


    scout_critical_threshold=(
    select
            decode(scout_crit_threshold_is_all,0,
                scout_critical_threshold,count(scout_id))
        from rhn_probe_state p, rhn_multi_scout_threshold t
        where t.probe_id=p.probe_id
          and state in ('OK', 'WARNING', 'CRITICAL')
             group by t.probe_id
        
    );
end;
$$
language plpgsql;



             
