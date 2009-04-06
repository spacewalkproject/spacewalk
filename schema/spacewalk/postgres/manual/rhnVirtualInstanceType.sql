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

create table
rhnVirtualInstanceType
(
	id			numeric not null
				primary key,
--				using index tablespace [[64k_tbs]]
	name			varchar(128) not null,
	label			varchar(128) not null,
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null,
				constraint rhn_vit_lbl_id_uq unique(label, id)
);

create sequence rhn_vit_id_seq;



--
