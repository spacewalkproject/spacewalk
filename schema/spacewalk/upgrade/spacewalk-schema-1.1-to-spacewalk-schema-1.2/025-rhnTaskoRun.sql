ALTER TABLE rhnTaskoRun DROP CONSTRAINT rhn_tasko_run_schedule_fk;
ALTER TABLE rhnTaskoRun ADD CONSTRAINT rhn_tasko_run_schedule_fk FOREIGN KEY (schedule_id) REFERENCES rhnTaskoSchedule(id) ON DELETE CASCADE;
