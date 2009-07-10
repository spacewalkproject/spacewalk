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

create table
rhnContentSourceType
(
	id		number
			constraint rhn_cst_id_nn not null
                        constraint rhn_cst_id_pk primary key,
	label		varchar2(32)
			constraint rhn_cst_label_nn not null
                        constraint rhn_cst_label_uq unique,
	created		date default(sysdate)
			constraint rhn_cst_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_cst_modified_nn not null
)
	enable row movement
  ;

create sequence rhn_content_source_type_id_seq start with 500;

create index rhn_ccst_id_l_idx
	on rhnContentSourceType(id,label)
	tablespace [[64k_tbs]]
  ;


insert into rhnContentSourceType (id, label) values
(rhn_content_source_type_id_seq.nextval, 'yum');

