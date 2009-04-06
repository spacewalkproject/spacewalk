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
rhnUserReserved
(
	login		varchar(64)
			not null,
	login_uc	varchar(64)
			not null
                        constraint rhn_user_res_login_uc_uq unique
--                        using index tablespace [[64k_tbs]]
                        ,
	password	varchar(38)
			not null,
        created         date default(current_date)
			not null,
        modified        date default(current_date)
			not null
)
 ;

--create or replace trigger
--rhn_user_res_mod_trig
--before insert or update on rhnUserreserved
--for each row
--begin
--	:new.login_uc := upper(:new.login);
--        :new.modified := sysdate;
--end;
--/
--show errors
--
--
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/06/11 17:07:04  cturner
-- update from misa
--
-- Revision 1.7  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
