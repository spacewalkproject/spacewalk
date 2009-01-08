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
-- Our idea of an RPM transaction.
--

create table
rhnTransaction
(
	id		number
			constraint rhn_trans_id_nn not null,
	server_id	number
			constraint rhn_trans_sid_nn not null
			constraint rhn_trans_sid_fk
				references rhnServer(id),
	timestamp	date
			constraint rhn_trans_ts_nn not null,
	rpm_trans_id	number
			constraint rhn_trans_rti_nn not null,
	label		varchar2(32),
	created		date default(sysdate)
			constraint rhn_trans_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_trans_modified_nn not null,
	constraint	rhn_trans_sid_rti_unq
			unique(server_id, rpm_trans_id)
			using index tablespace [[8m_tbs]]
)
	enable row movement
  ;

create sequence rhn_transaction_id_seq;

create index rhn_trans_id_sid_ts_rtid_idx
	on rhnTransaction(id,server_id,timestamp, rpm_trans_id)
  ;
alter table rhnTransaction add constraint rhn_trans_id_pk primary key (id)
	using index tablespace [[8m_tbs]];

--
-- Revision 1.6  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/12/23 21:56:12  misa
-- Fixed typo
--
-- Revision 1.3  2002/11/25 15:59:03  pjones
-- better indexing/pks/etc before it goes out :P
--
-- Revision 1.2  2002/09/25 19:09:02  pjones
-- transaction changes discussed today
--
-- Revision 1.1  2002/09/04 20:30:16  pjones
-- schema for transactions
--
