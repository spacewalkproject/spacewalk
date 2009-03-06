--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
-- monitoring data recieved from a system.

create table
rhnMonitor
(
    batch_id    numeric
    	    	not null,
    server_id	numeric
    	    	not null
		constraint rhn_monitor_sid_fk
		references rhnServer(id)
		on delete cascade,
    probe_id	numeric
    	    	not null,
    component	varchar(128),
    field	varchar(128),
    timestamp	date
    	    	not null,
    granularity	numeric
    		not null
		constraint rhn_monitor_granularity_fk
			references rhnMonitorGranularity(id),
    value       varchar(4000),
                constraint rhn_monitor_idx
                unique(server_id, probe_id, granularity, timestamp, component, field)
--              using index tablespace [[8m_tbs]]
)
  ;

create sequence rhn_monitor_bid_seq;

create index rhn_monitor_bid_idx
    	on rhnMonitor(batch_id)
--	tablespace [[8m_tbs]]
  ;

--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/08/13 19:17:58  pjones
-- cascades
--
-- Revision 1.4  2002/08/09 20:23:01  rnorwood
-- Added batch_id, with sequence and index
--
-- Revision 1.3  2002/08/09 20:13:02  pjones
-- timestamp number->date
--
-- Revision 1.2  2002/08/09 16:43:08  rnorwood
-- Remove "id" column from rhnMonitor, add index for most of the other columns
--
-- Revision 1.1  2002/08/07 18:12:42  pjones
-- add commit to rhnUserMessageStatus_data, check in everything else.
--
