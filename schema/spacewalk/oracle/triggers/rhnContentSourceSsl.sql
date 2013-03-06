--
-- Copyright (c) 2013 Red Hat, Inc.
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

create or replace trigger
rhn_cont_source_ssl_mod_trig
before insert or update on rhnContentSourceSsl
for each row
begin
	:new.modified := current_timestamp;
end;
/
show errors

create or replace trigger
rhn_csssl_ins_trig
before insert on rhnContentSourceSsl
for each row
when (new.id is null)
begin
    select sequence_nextval('rhn_contentsourcessl_seq') into :new.id from dual;
end;
/
show errors
