-- df like utility for Oracle
--
-- Originally from andrew, hacked by others
-- $Id$

select 
    a.name partition, 
    (a.free + b.used) size_MB,
    b.used used_MB,
    a.free free_MB,
    100*b.used/(a.free+b.used) percentage
from 
  ( select 
        tablespace_name name,
	sum(bytes)/1024/1024 free
    from user_free_space
    group by tablespace_name
  ) a,
  ( select
        tablespace_name name,
        sum(bytes)/1024/1024 used
    from user_segments
    group by tablespace_name
  ) b
  where a.name = b.name;

-- $Log$
-- Revision 1.1  2001/09/26 22:33:58  gafton
-- df for Oracle
--
