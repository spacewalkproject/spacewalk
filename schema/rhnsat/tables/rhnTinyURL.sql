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

