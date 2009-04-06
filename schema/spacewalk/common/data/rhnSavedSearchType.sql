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

insert into rhnSavedSearchType (id, label)
    values (rhn_sstype_id_seq.nextval, 'system');
insert into rhnSavedSearchType (id, label)
    values (rhn_sstype_id_seq.nextval, 'package');
insert into rhnSavedSearchType (id, label)
    values (rhn_sstype_id_seq.nextval, 'errata');
commit;

--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/15 20:51:26  pjones
-- add saved search schema
--
