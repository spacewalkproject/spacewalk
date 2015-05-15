delete from rhnTaskoRun where template_id in
       (select ttemp.id
	  from rhnTaskoTemplate ttemp,
	       rhnTaskoTask ttask
	 where ttemp.task_id = ttask.id
	   and ttask.name = 'cleanup-timeseries-data');

delete from rhnTaskoTemplate where task_id in (SELECT id FROM rhnTaskoTask WHERE name='cleanup-timeseries-data');

delete from rhnTaskoTask where name = 'cleanup-timeseries-data';
