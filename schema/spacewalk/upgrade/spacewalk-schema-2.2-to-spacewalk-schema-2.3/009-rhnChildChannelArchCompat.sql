--
-- Copyright (c) 2014 Red Hat, Inc.
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

CREATE TABLE rhnChildChannelArchCompat
(
    parent_arch_id  NUMBER NOT NULL
                         CONSTRAINT rhn_ccac_paid_fk
                             REFERENCES rhnChannelArch (id),
    child_arch_id  NUMBER NOT NULL
                         CONSTRAINT rhn_ccac_caid_fk
                             REFERENCES rhnChannelArch (id),
    created          timestamp with local time zone
                         DEFAULT (current_timestamp) NOT NULL,
    modified         timestamp with local time zone
                         DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_ccac_paid_caid
    ON rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnChildChannelArchCompat
    ADD CONSTRAINT rhn_ccac_paid_caid_uq UNIQUE (parent_arch_id, child_arch_id);


insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64'), LOOKUP_CHANNEL_ARCH('channel-ia64'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia32-deb'), LOOKUP_CHANNEL_ARCH('channel-ia32-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_CHANNEL_ARCH('channel-ia32-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ia64-deb'), LOOKUP_CHANNEL_ARCH('channel-ia64-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_CHANNEL_ARCH('channel-sparc'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc'), LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-deb'), LOOKUP_CHANNEL_ARCH('channel-sparc-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha'), LOOKUP_CHANNEL_ARCH('channel-alpha'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-alpha-deb'), LOOKUP_CHANNEL_ARCH('channel-alpha-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390'), LOOKUP_CHANNEL_ARCH('channel-s390'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390-deb'), LOOKUP_CHANNEL_ARCH('channel-s390-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390x'), LOOKUP_CHANNEL_ARCH('channel-s390'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-s390x'), LOOKUP_CHANNEL_ARCH('channel-s390x'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-iSeries'), LOOKUP_CHANNEL_ARCH('channel-iSeries'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-pSeries'), LOOKUP_CHANNEL_ARCH('channel-pSeries'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_CHANNEL_ARCH('channel-ia32'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-x86_64'), LOOKUP_CHANNEL_ARCH('channel-x86_64'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_CHANNEL_ARCH('channel-ia32-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-amd64-deb'), LOOKUP_CHANNEL_ARCH('channel-amd64-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc'), LOOKUP_CHANNEL_ARCH('channel-ppc'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-powerpc-deb'), LOOKUP_CHANNEL_ARCH('channel-powerpc-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm'), LOOKUP_CHANNEL_ARCH('channel-arm'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-armhfp'), LOOKUP_CHANNEL_ARCH('channel-armhfp'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-arm-deb'), LOOKUP_CHANNEL_ARCH('channel-arm-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-mips-deb'), LOOKUP_CHANNEL_ARCH('channel-mips-deb'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_CHANNEL_ARCH('channel-sparc'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'), LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_CHANNEL_ARCH('channel-sparc'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_CHANNEL_ARCH('channel-sparc-sun-solaris'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'), LOOKUP_CHANNEL_ARCH('channel-i386-sun-solaris'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-aarch64'), LOOKUP_CHANNEL_ARCH('channel-aarch64'));

insert into rhnChildChannelArchCompat (parent_arch_id, child_arch_id)
values (LOOKUP_CHANNEL_ARCH('channel-ppc64le'), LOOKUP_CHANNEL_ARCH('channel-ppc64le'));

commit;

