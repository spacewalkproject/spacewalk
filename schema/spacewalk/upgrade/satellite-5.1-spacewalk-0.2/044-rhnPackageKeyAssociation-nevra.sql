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
--/

create table
rhnPackageKeyAssociation
(
	package_id	number
			constraint rhn_pkeya_pid_nn not null 
			constraint rhn_pkeya_pid_fk
				references rhnPackage(id) on delete cascade,
	key_id	number
			constraint rhn_pkeya_kid_nn not null
			constraint rhn_pkeya_kid_fk
				references rhnPackageKey(id),
	created		date default (sysdate)
			constraint rhn_pkeya_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_pkeya_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_pkeya_pk_uq
	on rhnPackageKeyAssociation(package_id,key_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- Revision 1.1  2008/07/01 02:00:55  jlsherrill
-- initial add
