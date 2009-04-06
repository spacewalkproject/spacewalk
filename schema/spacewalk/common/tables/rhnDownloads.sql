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


CREATE TABLE rhnDownloads
(
    id                 NUMBER NOT NULL 
                           CONSTRAINT rhn_dl_id_pk PRIMARY KEY, 
    channel_family_id  NUMBER NOT NULL 
                           CONSTRAINT rhn_dl_cfid_fk
                               REFERENCES rhnChannelFamily (id), 
    file_id            NUMBER NOT NULL 
                           CONSTRAINT rhn_dl_fid_fk
                               REFERENCES rhnFile (id), 
    name               VARCHAR2(128) NOT NULL, 
    category           VARCHAR2(128) NOT NULL, 
    ordering           NUMBER NOT NULL, 
    download_type      NUMBER 
                           CONSTRAINT rhn_dl_dltype_fk
                               REFERENCES rhnDownloadType (id), 
    created            DATE 
                           DEFAULT (sysdate) NOT NULL, 
    modified           DATE 
                           DEFAULT (sysdate) NOT NULL, 
    release_notes_url  VARCHAR2(512)
)
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE rhn_download_id_seq;

