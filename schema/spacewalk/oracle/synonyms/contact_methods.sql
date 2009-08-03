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

--create special contact_methods synonyms for monitoring backend code to function as is

create or replace synonym contact_methods for rhn_contact_methods;
create or replace synonym contact_methods_recid_seq for rhn_contact_methods_recid_seq;

--
--
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
