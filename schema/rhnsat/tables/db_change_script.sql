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

create table
db_change_script
(
	bug_id		number
			constraint dc_script_bid_nn not null,
	seq_no		number
			constraint dc_script_sn_nn not null,
	owner		varchar2(255)
			constraint dc_script_owner_nn not null,
	description	varchar2(4000),
	release		varchar2(255),
	run_as		varchar2(255),
   expect_fail char(1) default 0
);

COMMENT ON TABLE db_change_script IS
	'DBCSC  Database change script meta-data';

create index dc_script_bid_sn_idx
	on db_change_script( bug_id, seq_no )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table db_change_script add constraint dc_script_bid_sn_pk
	primary key ( bug_id, seq_no );

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
