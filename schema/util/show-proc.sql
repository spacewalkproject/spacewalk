set pagesize 50000
select line||' '||text from all_source where name = upper('&name')
  and type in ('FUNCTION', 'PROCEDURE','PACKAGE BODY')
  ORDER by line;
