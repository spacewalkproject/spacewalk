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
rhnVirtualInstanceEventType
(
	id			number
				constraint rhn_viet_id_nn not null
				constraint rhn_viet_id_pk primary key
					using index tablespace [[64k_tbs]],
	name			varchar2(128)
				constraint rhn_viet_name_nn not null,
	label			varchar2(128)
				constraint rhn_viet_label_nn not null,
	created			date default (sysdate)
				constraint rhn_viet_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_viet_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_viet_id_seq;


-- $Log$
