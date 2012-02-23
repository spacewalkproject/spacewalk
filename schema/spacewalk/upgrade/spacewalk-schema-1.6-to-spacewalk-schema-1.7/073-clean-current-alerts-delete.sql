
delete from rhnTaskoRun
where template_id in (
	select id from rhnTaskoTemplate
	where task_id in (
		select id from rhnTaskoTask
		where class = 'com.redhat.rhn.taskomatic.task.CleanCurrentAlerts'
	)
);

delete from rhnTaskoTemplate
where task_id in (
	select id from rhnTaskoTask
	where class = 'com.redhat.rhn.taskomatic.task.CleanCurrentAlerts'
);

delete from rhnTaskoTask
where class = 'com.redhat.rhn.taskomatic.task.CleanCurrentAlerts';

delete from rhnTaskoSchedule
where bunch_id in (
	select id from rhnTaskoBunch
	where id not in (
		select bunch_id from rhnTaskoTemplate
	)
);

delete from rhnTaskoBunch
where id not in (
	select bunch_id from rhnTaskoTemplate
);

commit;

