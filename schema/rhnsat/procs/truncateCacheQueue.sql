--
-- $Id$
--

create or replace procedure  truncateCacheQueue as
begin
  execute immediate 'Truncate Table rhnOrgErrataCacheQueue';
end;
/

-- $Log$
-- Revision 1.2  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
