--
-- Copyright (c) 2012 Red Hat, Inc.
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
CREATE OR REPLACE VIEW
rhnOrgDistChannelMap
(
    id,
    for_org_id,
    org_id,
    os,
    release,
    channel_arch_id,
    channel_id
)
AS
SELECT CASE WHEN dcm_o.org_id IS NOT NULL THEN dcm_o.id ELSE dcm_n.id END id,
        o.id as for_org_id,
        dcm_o.org_id,
        CASE WHEN dcm_o.org_id IS NOT NULL THEN dcm_o.os ELSE dcm_n.os END os,
        CASE WHEN dcm_o.org_id IS NOT NULL THEN dcm_o.release ELSE dcm_n.release END as release,
        CASE WHEN dcm_o.org_id IS NOT NULL THEN dcm_o.channel_arch_id ELSE dcm_n.channel_arch_id END as channel_arch_id,
        CASE WHEN dcm_o.org_id IS NOT NULL THEN dcm_o.channel_id ELSE dcm_n.channel_id END as channel_id
FROM web_customer o
    JOIN (SELECT DISTINCT release, channel_arch_id from rhnDistChannelMap) dcm ON 1 = 1
    LEFT JOIN rhnDistChannelMap dcm_n ON dcm_n.org_id IS NULL
        AND dcm_n.release = dcm.release
        AND dcm_n.channel_arch_id = dcm.channel_arch_id
    LEFT JOIN rhnDistChannelMap dcm_o ON dcm_o.org_id = o.id
        AND dcm_o.release = dcm.release
        AND dcm_o.channel_arch_id = dcm.channel_arch_id
WHERE (dcm_o.channel_id IS NOT NULL OR dcm_n.channel_id IS NOT NULL)
ORDER BY org_id, release, channel_arch_id;
