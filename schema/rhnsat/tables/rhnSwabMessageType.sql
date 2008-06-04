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
-- XXX: should be dev
-- EXCLUDE: all

CREATE TABLE
rhnSwabMessageType
(
	id		number
			constraint rhn_swab_msg_t_id_nn not null
			constraint rhn_swab_msg_t_id_pk primary key,
	label		varchar2(256)
	    	    	constraint rhn_swab_msg_t_type_nn not null,
	rate		number(10,2) default 1.0
	    	    	constraint rhn_swab_msg_t_rate_nn not null
			constraint rhn_swab_msg_t_rate_sane
				check (rate > 0 and rate <= 60.0)
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_swab_message_t_seq;

create unique index rhn_swab_message_t_label_uq
	on rhnSwabMessageType(label)
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
