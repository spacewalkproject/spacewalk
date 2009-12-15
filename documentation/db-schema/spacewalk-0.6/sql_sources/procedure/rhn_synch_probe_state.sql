-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."RHN_SYNCH_PROBE_STATE" 
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
