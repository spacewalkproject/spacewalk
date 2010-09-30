-- oracle equivalent source sha1 dcba39e9ac47e185b7c4a00358da57c5f0cb7753
-- retrieved from ./1281907152/e7d83f4713db9bbaf0290f57423fba85ded8d317/schema/spacewalk/oracle/quartz/data/qrtz.sql
-- Thanks to Patrick Lightbody for submitting this...
--
-- In your Quartz properties file, you'll need to set
-- org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.PostgreSQLDelegate

INSERT INTO qrtz_locks values('TRIGGER_ACCESS');
INSERT INTO qrtz_locks values('JOB_ACCESS');
INSERT INTO qrtz_locks values('CALENDAR_ACCESS');
INSERT INTO qrtz_locks values('STATE_ACCESS');
INSERT INTO qrtz_locks values('MISFIRE_ACCESS');
