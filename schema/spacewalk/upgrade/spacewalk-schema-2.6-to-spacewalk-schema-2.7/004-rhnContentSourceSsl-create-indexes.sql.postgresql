-- oracle equivalent source sha1 ba5c28a4469ef2df0238caa2d199f1829d4f390d
--
-- Copyright (c) 2017 Red Hat, Inc.
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

CREATE UNIQUE INDEX rhn_csssl_ca_uq
    ON rhnContentSourceSsl (content_source_id, ssl_ca_cert_id)
    WHERE ssl_client_cert_id IS NULL AND ssl_client_key_id IS NULL;

CREATE UNIQUE INDEX rhn_csssl_ca_cert_uq
    ON rhnContentSourceSsl (content_source_id, ssl_ca_cert_id, ssl_client_cert_id)
    WHERE ssl_client_cert_id IS NOT NULL AND ssl_client_key_id IS NULL;

CREATE UNIQUE INDEX rhn_csssl_ca_cert_key_uq
    ON rhnContentSourceSsl (content_source_id, ssl_ca_cert_id, ssl_client_cert_id, ssl_client_key_id)
    WHERE ssl_client_cert_id IS NOT NULL AND ssl_client_key_id IS NOT NULL;
