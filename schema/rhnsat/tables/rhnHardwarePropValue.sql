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
-- EXCLUDE: all
--

create sequence rhn_hwpropval_id_seq;

create table
rhnHardwarePropValue
(
	id			number
				constraint rhn_hwpropval_id_nn not null,
	value			varchar2(256),
	csum			number
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_hwpropval_id_idx
	on rhnHardwarePropValue ( id ) 
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnHardwarePropValue add constraint rhn_hwpropval_id_pk
	primary key ( id );

create index rhn_hwpropval_csum_id_idx
	on rhnHardwarePropValue ( csum, id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnHardwarePropValue add constraint rhn_hwpropval_csum_uq
	unique ( csum );

--create or replace trigger
--rhn_hwpropval_mod_trig
--before insert or update on rhnHardwarePropValue
--for each row
--begin
--	-- if this becomes slow, we can look at recomputing csum
--	-- when it's more strictly necessary.  It's probably not worth
--	-- it just yet.  I really doubt if this is actually needed anyway.
--	if :new.csum is null then
--		:new.csum := adler32(:new.value);
--	end if;
--end;
--/
--show errors

-- $Log$
-- Revision 1.6  2003/08/20 16:36:07  pjones
-- bugzilla: none
--
-- disable rhnHardware
--
-- Revision 1.5  2003/06/22 20:03:44  pjones
-- bugzilla: none
-- syntax is busted completely on the trigger; fixed now
--
-- Revision 1.4  2003/06/19 22:08:46  pjones
-- bugzilla: 84125
--
-- New hardware schema.  This looks pretty final, but conversion is still
-- a work in progress.
--
-- Revision 1.3  2003/03/05 00:05:38  pjones
-- make it a bit faster, mostly
--
-- Revision 1.2  2003/03/04 17:15:31  pjones
-- null ok for hw prop values
-- add some more lookup functions
-- minor bugfixes in old lookup functions
-- deps
--
-- Revision 1.1  2003/02/27 00:35:12  pjones
-- new hardware tables
-- lookup functions and conversion scripts to come tomorrow
-- Also todo: makefile.deps
--
