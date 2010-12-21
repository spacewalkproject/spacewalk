#
# Copyright (c) 2008--2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

use strict;

package Dobby::Reporting;
use Dobby::DB;

sub tablespace_overview {
  my $class = shift;
  my $dobby = shift;

  my $dbh = $dobby->sysdba_connect;

  my $query = <<EOQ;
SELECT DT.tablespace_name as NAME, DT.extent_management, DT.contents,
       case DT.contents when 'TEMPORARY' then DF.total_bytes-NVL(DTF.used_bytes,0) else NVL(DFS.free_bytes,0) end as free_bytes,
       case DT.contents when 'TEMPORARY' then NVL(DTF.used_bytes,0) else DF.total_bytes-NVL(DFS.free_bytes,0) end as used_bytes,
       DF.total_bytes
  FROM dba_tablespaces DT
  JOIN (SELECT tablespace_name, sum(bytes) as total_bytes
          FROM dba_data_files
         GROUP BY tablespace_name
         UNION
        SELECT tablespace_name, SUM(bytes) as total_bytes
          FROM dba_temp_files
         GROUP BY tablespace_name) DF
    on DT.tablespace_name = DF.tablespace_name
  LEFT JOIN (SELECT tablespace_name, SUM(bytes) as free_bytes
               FROM dba_free_space
              GROUP BY tablespace_name) DFS
    on DT.tablespace_name = DFS.tablespace_name
  LEFT JOIN (SELECT u.tablespace, sum(u.blocks* p.value) as used_bytes
               FROM v\$tempseg_usage u,
                    v\$parameter p
              WHERE p.name = 'db_block_size'
              GROUP BY u.tablespace) DTF
    on DT.tablespace_name = DTF.tablespace
ORDER BY DT.tablespace_name
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute;
  return $sth->fullfetch_hashref;
}

sub table_size_overview {
  my $class = shift;
  my $dobby = shift;

  my $dbh = $dobby->sysdba_connect;

  my $query = <<EOQ;
SELECT de.segment_name AS NAME, SUM(de.bytes) AS TOTAL_BYTES
  FROM dba_tables dt, dba_extents de
 WHERE de.owner = 'RHNSAT'
   AND dt.table_name = de.segment_name
GROUP BY de.segment_name
ORDER BY de.segment_name
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute;
  return $sth->fullfetch_hashref;
}

sub segadv_recomendations {
  my $class = shift;
  my $dobby = shift;

  my $dbh = $dobby->connect;

  my $query = <<EOQ;
SELECT tbs.segment_space_management, rec.*
  FROM TABLE(DBMS_SPACE.ASA_RECOMMENDATIONS()) rec,
       dba_tablespaces tbs
 WHERE rec.tablespace_name = tbs.tablespace_name
 ORDER BY segment_space_management asc, segment_type desc, reclaimable_space desc
EOQ
  my $sth = $dbh->prepare($query);
  $sth->execute;
  return $sth->fullfetch_hashref;
}

1;
