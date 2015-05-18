delete from rhnTaskoRun where template_id in
       (select ttemp.id
	  from rhnTaskoTemplate ttemp,
	       rhnTaskoTask ttask
	 where ttemp.task_id = ttask.id
	   and ttask.name = 'cleanup-timeseries-data');

delete from rhnTaskoTemplate where task_id in (SELECT id FROM rhnTaskoTask WHERE name='cleanup-timeseries-data');
update rhnTaskoTemplate set ordering=0 where bunch_id in (SELECT id FROM rhnTaskoBunch WHERE name='cleanup-data-bunch') and task_id in (SELECT id FROM rhnTaskoTask WHERE name='cleanup-packagechangelog-data');

delete from rhnTaskoTask where name = 'cleanup-timeseries-data';
