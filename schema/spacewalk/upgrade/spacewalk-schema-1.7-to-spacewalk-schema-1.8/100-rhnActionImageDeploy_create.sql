--
-- Copyright (c) 2012 Novell
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

CREATE TABLE rhnActionImageDeploy
(
    id            NUMBER NOT NULL
                  CONSTRAINT rhn_aid_id_pk PRIMARY KEY
                  USING INDEX TABLESPACE [[64k_tbs]],
    action_id     NUMBER NOT NULL
                      CONSTRAINT rhn_act_idp_act_fk
                      REFERENCES rhnAction (id)
                      ON DELETE CASCADE,
    vcpus         NUMBER NOT NULL,
    mem_kb        NUMBER NOT NULL,
    bridge_device VARCHAR2(32),
    download_url  VARCHAR2(256) NOT NULL,
    proxy_server  VARCHAR2(64),
    proxy_user    VARCHAR2(32),
    proxy_pass    VARCHAR2(64)
)
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE rhn_action_image_deploy_id_seq;
