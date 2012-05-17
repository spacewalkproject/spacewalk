--
-- Copyright (c) 2010 Red Hat, Inc.
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


CREATE TABLE rhnPackageChangeLogData
(
    id          NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_cld_id_pk PRIMARY KEY
                    USING INDEX TABLESPACE [[64k_tbs]],
    name        VARCHAR2(128) NOT NULL,
    text        VARCHAR2(3000) NOT NULL,
    time        DATE NOT NULL,
    created     DATE
                    DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_pkg_cld_nt_idx
    ON rhnPackageChangeLogData (name, time)
    NOLOGGING
    TABLESPACE [[32m_tbs]];

CREATE SEQUENCE rhn_pkg_cld_id_seq;

CREATE TABLE rhnPackageChangeLogRec
(
    id          NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_clr_id_pk PRIMARY KEY
                    USING INDEX TABLESPACE [[64k_tbs]],
    package_id  NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_clr_pid_fk
                        REFERENCES rhnPackage (id)
                        ON DELETE CASCADE,
    changelog_data_id  NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_clr_cld_fk
                        REFERENCES rhnPackageChangeLogData (id),
    created     DATE
                    DEFAULT (sysdate) NOT NULL,
    modified    DATE
                    DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_pkg_clr_pid_cld_uq
    ON rhnPackageChangeLogRec (package_id, changelog_data_id)
    NOLOGGING
    TABLESPACE [[32m_tbs]];

CREATE INDEX rhn_pkg_clr_cld_uq
    ON rhnPackageChangeLogRec (changelog_data_id)
    NOLOGGING
    TABLESPACE [[32m_tbs]];

-- Split rhnPackageChangelog data into the two tables.

insert /*+append*/ into rhnPackageChangeLogData (id, name, text, time, created)
select min(id), name, text, time, min(created)
from rhnPackageChangelog
group by name, text, time;

commit;

declare
	max_id integer;
	i integer;
begin
	select max(id), min(id) into max_id, i from rhnPackageChangeLog;
	while i <= max_id loop
		insert /*+append*/ into rhnPackageChangelogRec (id, package_id, changelog_data_id, created, modified)
		select rhnPackageChangeLog.id, rhnPackageChangeLog.package_id, rhnPackageChangeLogData.id, rhnPackageChangeLog.created, rhnPackageChangeLog.modified
		from rhnPackageChangeLog, rhnPackageChangeLogData
		where rhnPackageChangeLog.name = rhnPackageChangeLogData.name
			and rhnPackageChangeLog.text = rhnPackageChangeLogData.text
			and rhnPackageChangeLog.time = rhnPackageChangeLogData.time
			and rhnPackageChangeLog.id >= i
			and rhnPackageChangeLog.id < i + 10000;
		commit;
		i := i + 10000;
	end loop;
end;
/

drop table rhnPackageChangelog;

-- Bump up the nextval of rhn_pkg_cld_id_seq to be above
-- the current max valu in rhnPackageChangeLogData.
begin
	for rec in (
		select id - rhn_pkg_cld_id_seq.nextval id from ( select nvl(max(id), 0) id from rhnPackageChangeLogData )
		) loop
		execute immediate 'alter sequence rhn_pkg_cld_id_seq increment by ' || greatest(rec.id, 1);
	end loop;
	for rec in (
		select rhn_pkg_cld_id_seq.nextval from dual
		) loop
		null;
	end loop;
	execute immediate 'alter sequence rhn_pkg_cld_id_seq increment by 1';
end;
/


create view rhnPackageChangeLog
as
select rhnPackageChangeLogRec.id,
	rhnPackageChangeLogRec.package_id,
	rhnPackageChangeLogRec.changelog_data_id,
	rhnPackageChangeLogData.name,
	rhnPackageChangeLogData.text,
	rhnPackageChangeLogData.time,
	rhnPackageChangeLogRec.created,
	rhnPackageChangeLogRec.modified
from rhnPackageChangeLogRec, rhnPackageChangeLogData
where rhnPackageChangeLogRec.changelog_data_id = rhnPackageChangeLogData.id;

