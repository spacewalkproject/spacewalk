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


ALTER TABLE rhnRegTokenPackages ADD id number;

CREATE SEQUENCE rhn_reg_tok_pkg_id_seq;

UPDATE rhnRegTokenPackages SET id = rhn_reg_tok_pkg_id_seq.nextval;

ALTER TABLE rhnRegTokenPackages ADD CONSTRAINT rhn_reg_tok_pkg_id_nn  CHECK ("ID" IS NOT NULL);

ALTER TABLE rhnRegTokenPackages ADD CONSTRAINT rhn_reg_tok_pkg_id_pk primary key ( id );

ALTER TABLE rhnRegTokenPackages ADD (arch_id number);

ALTER TABLE rhnRegTokenPackages ADD CONSTRAINT rhn_reg_tok_pkg_aid_fk FOREIGN KEY (arch_id) REFERENCES rhnPackageArch (id) ON DELETE CASCADE;

DROP index rhn_reg_tok_pkg_uq;

create unique index rhn_reg_tok_pkg_uq
        on rhnRegTokenPackages(id, token_id, name_id, arch_id)
        tablespace [[4m_tbs]]
        storage( freelists 16 )
        initrans 32;


show errors

-- $Log$
-- Revision 1  2008/12/04 10:44 pkilambi
-- Arch support for activation key based package installs

