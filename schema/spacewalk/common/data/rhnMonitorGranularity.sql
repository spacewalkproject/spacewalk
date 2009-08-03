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
--
-- data for rhnMonitorGranularity

insert into rhnMonitorGranularity values (
	rhn_monitorgranularity_id_seq.nextval, 'daily'
);
commit;

--
-- Revision 1.1  2002/08/07 18:12:42  pjones
-- add commit to rhnUserMessageStatus_data, check in everything else.
--
