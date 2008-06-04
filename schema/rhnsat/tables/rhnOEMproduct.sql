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
-- EXCLUDE: all

create table
rhnOEMproduct
(
        id              number
                        constraint rhn_oem_product_id_nn not null
                        constraint rhn_oem_product_id_pk primary key,
        web_user_id     number
                        constraint rhn_oem_product_wuid_nn not null
                        constraint rhn_oem_product_wuid_fk
                                references web_contact(id)
				on delete cascade,
        product_id      number
                        constraint rhn_oem_product_pid_nn not null
                        constraint rhn_oem_product_pid_fk
                                references rh_product_xref(product_id)
                                on delete cascade,
        oem_name        varchar2(16)
                        constraint rhn_oem_product_on_nn not null,
        created         date default(sysdate)
                        constraint rhn_oem_product_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_oem_product_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_oem_product_id_seq;

create unique index rhn_oem_product_wuid_pid_uq
	on rhnOEMproduct(web_user_id,product_id)
	tablespace [[main_index_tablespace]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_oem_products_mod_trig
before insert or update on rhnOEMproduct
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.12  2005/01/10 22:47:19  cturner
-- bugzilla: 144722, changes for www renewal push
--
-- Revision 1.11  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/09 21:04:34  pjones
-- these aren't for sat
--
-- Revision 1.8  2002/05/08 23:10:12  gafton
-- Make file exclusion work correctly
--
-- Revision 1.7  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[main_index_tablespace]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.6  2001/12/27 18:22:01  pjones
-- policy change: foreign keys to other users' tables now _always_ go to
-- a synonym.  This makes satellite schema (where web_contact is in the same
-- namespace as rhn*) easier.
--
-- Revision 1.5  2001/07/25 09:04:48  pjones
-- another like the last.
--
-- Revision 1.4  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.3  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.2  2001/06/27 02:18:12  pjones
-- triggers
--
-- Revision 1.1  2001/06/27 01:46:05  pjones
-- initial checkin
--
--
--/

