-- delete orphaned data from state_change
delete from state_change sc where sc.o_id not in (select rp.recid || '' from rhn_probe rp);

-- delete orphaned data from rhn_probe_state
delete from rhn_probe_state rps where rps.probe_id not in (select rp.recid from rhn_probe rp);
