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
-- data for rhnEmailAddressState

insert into rhnEmailAddressState ( id, label )
	values (nextval('rhn_eastate_id_seq'), 'unverified');
insert into rhnEmailAddressState ( id, label )
	values (nextval('rhn_eastate_id_seq'), 'pending');
insert into rhnEmailAddressState ( id, label )
	values (nextval('rhn_eastate_id_seq'), 'pending_warned');
insert into rhnEmailAddressState ( id, label )
	values (nextval('rhn_eastate_id_seq'), 'verified');
insert into rhnEmailAddressState ( id, label )
	values (nextval('rhn_eastate_id_seq'), 'needs_verifying');
	

--
-- Revision 1.3  2003/01/22 18:48:37  cturner
-- rename column, add intermediary email step
--
-- Revision 1.2  2003/01/14 05:24:27  cturner
-- needs_verifying state will be the default new sdtate now, allowing unverified to simply be legacy
--
-- Revision 1.1  2003/01/10 17:44:02  pjones
-- new email address table
--
