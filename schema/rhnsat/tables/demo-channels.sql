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
-- $Id$
--
-- EXCLUDE: all

INSERT INTO rhnChannelFamily (id, label, name, purchasable) VALUES (rhn_channel_family_id_seq.nextval, 'demo-private', 'Private Channels for Demo Account', 0);


insert into rhnChannel
SELECT
	rhn_channel_id_seq.nextval, c.id, 
	(select org_id from web_contact where login_uc = 'RHNDEMO'), 
	c.arch_family_id, 'private-demo-' || c.label, '/',
	'Private Subchannel of ' || c.name, 
	'Private Subchannel of ' || c.name, 
	NULL, sysdate, sysdate, sysdate
  FROM rhnChannel C
 WHERE C.label LIKE 'redhat-linux-i386-%' and C.label not like '%staging%';

INSERT INTO rhnChannelFamilyMembers
(channel_family_id, channel_id)
SELECT (select id from rhnchannelfamily where label = 'demo-private'),
       c.id
 from rhnchannel c
where c.label like 'private-demo-%';

INSERT INTO rhnChannelFamilyPermissions
(channel_family_id, org_id)
values
((select id from rhnchannelfamily where label = 'demo-private'), 
 (select org_id from web_contact where login_uc = 'RHNDEMO'));

commit;

-- $Log$
-- Revision 1.4  2002/11/13 00:15:49  pjones
-- rhnArch.label changes
--
-- Revision 1.3  2002/05/09 20:52:41  pjones
-- these don't need get imported currently.
-- eventually, ResponsysUsers* should.
--
-- Revision 1.2  2002/05/08 23:10:12  gafton
-- Make file exclusion work correctly
--
