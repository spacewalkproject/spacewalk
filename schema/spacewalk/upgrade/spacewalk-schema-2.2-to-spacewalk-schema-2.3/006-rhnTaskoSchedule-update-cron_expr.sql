update rhnTaskoSchedule set cron_expr = '0 * * * * ?' where job_label = 'errata-cache-default';
