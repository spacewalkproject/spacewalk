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
rhnServerTokenRegs
(
	token_id	numeric
			not null
			constraint rhn_srv_reg_tok_tid_fk
				references rhnRegToken(id)
				on delete cascade,
	server_id	numeric
			not null
			constraint rhn_srv_reg_tok_sid_fk
				references rhnServer(id)
)
  ;

create index rhn_srv_reg_tok_ts_idx
	on rhnServerTokenRegs(token_id, server_id)
--      tablespace [[64k_tbs]]
	;

create index RHN_SRVR_TKN_RGS_SID_TID_IDX
on rhnServerTokenRegs ( server_id, token_id )
--      tablespace [[64k_tbs]]
        ;

--
-- Revision 1.8  2004/05/27 23:00:59  pjones
-- bugzilla: 123639 -- this unique constraint is crack.
--
-- Revision 1.7  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.6  2003/04/14 15:40:16  pjones
-- one more layer on the cascades...
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
