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
--
--
--

create or replace view rhnUserReceiveNotifications
as
    select wc.org_id, usp.user_id, usp.server_id
    from rhnUserServerPerms usp
    left join rhnWebContactDisabled wcd
        on usp.user_id = wcd.id
    join web_contact wc
        on usp.user_id = wc.id
    join rhnUserInfo ui
        on usp.user_id = ui.user_id
        and ui.email_notify = 1
    join web_user_personal_info upi
        on usp.user_id = upi.web_user_id
        and upi.email is not null
    left join rhnUserServerPrefs uspr
        on uspr.server_id = usp.server_id
        and usp.user_id = uspr.user_id
        and uspr.name = 'receive_notifications'
        and value='0'
    where uspr.server_id is null
    and wcd.id is null;
