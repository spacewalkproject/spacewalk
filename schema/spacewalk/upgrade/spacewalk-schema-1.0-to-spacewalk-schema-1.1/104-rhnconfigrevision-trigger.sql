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

create or replace trigger
rhn_confrevision_mod_trig
before insert or update on rhnConfigRevision
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- right now we're not doing accounting for rhnConfigRevision updates.
-- we shouldn't ever _do_ updates, but right now the perms exist.
create or replace trigger
rhn_confrevision_acct_trig
after insert on rhnConfigRevision
for each row
declare
	org_id number;
	available number := 0;
	added number := 0;
begin
	-- find the current amount of quota available
    begin
	select	cc.org_id id,
			oq.total + oq.bonus - oq.used available,
			content.file_size added
	into	org_id, available, added
	from	rhnConfigContent	content,
			rhnOrgQuota			oq,
			rhnConfigChannel	cc,
			rhnConfigFile		cf
	where	cf.id = :new.config_file_id
			and cf.config_channel_id = cc.id
			and cc.org_id = oq.org_id
            and :new.config_file_type_id = (select id from rhnConfigFileType where label='file')
			and :new.config_content_id = content.id;
    exception
            when no_data_found then
                added := 0;
                available := 0;
    end;            
	if added > available then
		rhn_exception.raise_exception('not_enough_quota');
	end if;
end;
/
show errors

create or replace trigger
rhn_confrevision_del_trig
before delete on rhnConfigRevision
for each row
declare
	cursor snapshots is
		select	snapshot_id id
		from	rhnSnapshotConfigRevision
		where	config_revision_id = :old.id;
begin
	for snapshot in snapshots loop
		update rhnSnapshot
			set invalid = lookup_snapshot_invalid_reason('cr_removed')
			where id = snapshot.id;
		delete from rhnSnapshotConfigRevision
			where snapshot_id = snapshot.id
				and config_revision_id = :old.id;
	end loop;
end;
/
show errors

--
--
-- Revision 1.4  2004/01/07 20:49:12  pjones
-- bugzilla: none -- this needs to be done in application code
--
-- Revision 1.3  2004/01/05 20:35:41  pjones
-- bugzilla: 112553 -- fix the insert case for quota
--
-- Revision 1.2  2003/12/19 22:07:30  pjones
-- bugzilla: 112392 -- quota support for config files
--
-- Revision 1.1  2003/11/14 21:00:44  pjones
-- bugzilla: none -- snapshot invalid on config rev removal
--
