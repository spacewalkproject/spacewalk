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
-- $Id$
--

CREATE TABLE
rhnTinyURL
(
        token           varchar2(64)
                        constraint rhn_tu_token_nn not null,
        url             varchar2(512)
                        constraint rhn_tu_url_nn not null,
        enabled         varchar2(1)
                        constraint rhn_tu_enabled_nn not null
                        constraint rhn_tu_enabled_ck
                                check (enabled in ('Y','N')),
        created         date default (sysdate)
                        constraint rhn_tu_created_nn not null,
        expires         date default (sysdate)
                        constraint rhn_tu_expires_nn not null
)
        storage ( freelists 16 )
        initrans 32;

create unique index rhn_tu_token_uq
        on rhnTinyURL(token)
        tablespace [[2m_tbs]]
        storage ( freelists 16 )
        initrans 32;

