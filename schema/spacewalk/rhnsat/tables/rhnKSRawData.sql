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
-- $Id$
--

/*
create table
rhnKSRawData
(
    kickstart_id      number
            constraint rhn_ks_raw_data_tid_nn not null
			constraint rhn_ks_raw_data_fk
				references rhnKSData(id)
                on delete cascade,
    data	blob
)	
    storage ( freelists 16 )
	enable row movement
	initrans 32;

/
show errors

*/
-- $Log$
-- Revision 1  2008/10/01 7:01:05  paji
-- basically created the KsRawData schema
