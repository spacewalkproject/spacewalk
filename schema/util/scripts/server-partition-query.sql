-- okay this query will show you the number of servers in a given
-- block of servers (I suggest 10k-25k) that have checked in within a
-- given time period.  this will help us determine what partition
-- sizes should be used.  the output is the server id window, then the
-- ratio of how many have spoken to our servers within checkin_window
-- days, then the percent version of that ratio

COLUMN RATIO FORMAT 999.99
COLUMN RATIO_STRING FORMAT A30

SELECT X.BLOCK_START, X.BLOCK_START + &&block_size,
       (SELECT COUNT(1) FROM rhnServerInfo SI WHERE SI.server_id BETWEEN X.BLOCK_START AND X.BLOCK_START + &&block_size AND SI.checkin > sysdate - &&checkin_window)
       || '/' || 
       (SELECT COUNT(1) FROM rhnServer S WHERE S.id BETWEEN X.BLOCK_START AND X.BLOCK_START + &&block_size) RATIO_STRING,
       100 * (SELECT COUNT(1) FROM rhnServerInfo SI WHERE SI.server_id BETWEEN X.BLOCK_START AND X.BLOCK_START + &&block_size AND SI.checkin > sysdate - &&checkin_window)
       / 
       (SELECT COUNT(1) FROM rhnServer S WHERE S.id BETWEEN X.BLOCK_START AND X.BLOCK_START + &&block_size) RATIO
  FROM (SELECT DISTINCT S.id - MOD(S.id, &&block_size) BLOCK_START
          FROM rhnServer S) X
ORDER BY X.BLOCK_START
   
/
