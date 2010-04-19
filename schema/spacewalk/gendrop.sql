-- Generate all drop staements for the current schema
--
-- $Id$

set pagesize 10000

select 'whenever sqlerror exit failure' from dual
union
select
    'drop ' || lower(object_type) || ' ' || lower(object_name) || ';' DROP_STATEMENT
from
    user_objects
where
    lower(object_type) not in ('table', 'index', 'trigger', 'lob')
UNION
select
    'drop ' || lower(object_type) || ' ' || lower(object_name) || ' cascade constraints;'
    DROP_STATEMENT
from
    user_objects
where
    lower(object_type) = 'table'
    and object_name not like '%$%';

quit;
