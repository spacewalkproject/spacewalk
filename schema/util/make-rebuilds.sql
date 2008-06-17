select 'alter view ' || object_name ||' compile;'
from user_objects
where object_type = 'VIEW' and status != 'VALID';

select distinct 'alter package ' || object_name ||' compile;'
from user_objects
where object_type in ('PACKAGE','PACKAGE BODY') and status != 'VALID';

select 'alter procedure ' || object_name || ' compile;'
from user_objects
where object_type = 'PROCEDURE' and status != 'VALID';

select 'alter ' || object_type || ' ' || object_name || ' compile;'
from user_objects
where object_type != 'PACKAGE BODY' and status != 'VALID';

quit
