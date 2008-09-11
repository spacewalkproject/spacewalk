--
-- $Id$
--

create or replace procedure  truncateCacheQueue as
curnum number;
begin
curnum  := dbms_sql.open_cursor;
dbms_sql.parse(curnum, 'Truncate Table rhnOrgErrataCacheQueue', dbms_sql.v7);
dbms_sql.close_cursor(curnum);
end;
/

-- $Log$
-- Revision 1.2  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
