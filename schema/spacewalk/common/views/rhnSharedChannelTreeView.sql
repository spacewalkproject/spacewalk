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

CREATE OR REPLACE VIEW RHNSHAREDCHANNELTREEVIEW
(
  ORG_ID,
  ID,
  DEPTH,
  NAME,
  PADDED_NAME,
  CHANNEL_ARCH_ID,
  LAST_MODIFIED,
  LABEL,
  PARENT_OR_SELF_LABEL,
  PARENT_OR_SELF_ID,
  END_OF_LIFE
)
AS
SELECT * FROM (
  SELECT
    C.ORG_TRUST_ID AS ORG_ID,
    C.ID,
    1 AS DEPTH,
    C.NAME,
    '  '||C.NAME AS PADDED_NAME,
    C.CHANNEL_ARCH_ID,
    C.LAST_MODIFIED,
    C.LABEL,
    C.LABEL AS PARENT_OR_SELF_LABEL,
    C.ID AS PARENT_OR_SELF_ID,
    C.END_OF_LIFE
  FROM RHNSHAREDCHANNELVIEW C
  WHERE C.PARENT_CHANNEL IS NULL
  UNION
  SELECT
    C.ORG_TRUST_ID AS ORG_ID,
    C.ID,
    2 AS DEPTH,
    c.name,
    ''||C.NAME AS PADDED_NAME,
    C.CHANNEL_ARCH_ID,
    C.LAST_MODIFIED,
    C.LABEL,
    PC.LABEL AS PARENT_OR_SELF_LABEL,
    PC.ID AS PARENT_OR_SELF_ID,
    C.END_OF_LIFE
  FROM RHNCHANNEL PC,
       RHNSHAREDCHANNELVIEW C
  WHERE C.PARENT_CHANNEL = PC.ID
) SHARRED
ORDER BY PARENT_OR_SELF_LABEL, PARENT_OR_SELF_ID;

