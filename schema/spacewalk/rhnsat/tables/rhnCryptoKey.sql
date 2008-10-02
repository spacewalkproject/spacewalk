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

create sequence rhn_cryptokey_id_seq;

create table
rhnCryptoKey
(
	id			number
				constraint rhn_cryptokey_id_nn not null
				constraint rhn_cryptokey_id_pk primary key
					using index tablespace [[2m_tbs]],
	org_id			number
				constraint rhn_cryptokey_oid_nn not null
				constraint rhn_cryptokey_oid_fk
					references web_customer(id)
					on delete cascade,
	description		varchar2(1024)
				constraint rhn_cryptokey_desc_nn not null,
	crypto_key_type_id	number
				constraint rhn_cryptokey_cktid_nn not null
				constraint rhn_cryptokey_cktid_fk
					references rhnCryptoKeyType(id),
	key			blob
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_cryptokey_oid_desc_uq
	on rhnCryptoKey( org_id, description )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
--
-- Revision 1.5  2004/04/08 20:43:15  pjones
-- bugzilla: 120297 -- make description unique within an org
--
-- Revision 1.4  2003/11/17 12:51:25  misa
-- Typo
--
-- Revision 1.3  2003/11/14 19:51:51  pjones
-- bugzilla: none -- add description, too
--
-- Revision 1.2  2003/11/14 19:43:48  pjones
-- bugzilla: none -- org_id on rhnCryptoKey
--
-- Revision 1.1  2003/11/13 15:29:17  pjones
-- bugzilla: 109896 -- add schema to hold cryptographic keys
--
