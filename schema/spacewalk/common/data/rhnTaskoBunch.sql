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


INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'daily-status', 'daily-status description', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'sat-sync', 'sat-sync description', 'Y', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'clear-tasko-log-history', 'Clears taskomatic run log history', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'cobbler-sync-bunch', 'Applies any cobbler configuration changes,', '', sysdate);

commit;
