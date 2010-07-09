/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.frontend.action.configuration.test;

import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * FileDownloadActionTest
 * @version $Rev$
 */
public class FileDownloadActionTest extends RhnMockStrutsTestCase {

        public void testPlaintextExecute() throws Exception {
            UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
            UserTestUtils.addProvisioning(user.getOrg());

            ConfigRevision revision = ConfigTestUtils.createConfigRevision(user.getOrg());

            setRequestPathInfo("/configuration/file/FileDownload");
            addRequestParameter("cfid", revision.getConfigFile().getId().toString());
            addRequestParameter("crid", revision.getId().toString());
            actionPerform();
            assertNotNull(request.getParameter("cfid"));
            String contentType = response.getContentType();
            assertTrue(contentType.startsWith("text/plain"));

            revision = ConfigTestUtils.createConfigRevision(user.getOrg());
            revision.getConfigContent().setBinary(true);
            ConfigurationFactory.commit(revision);
        }

        public void testBinaryExecute() throws Exception {
            UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
            UserTestUtils.addProvisioning(user.getOrg());

            ConfigRevision revision = ConfigTestUtils.createConfigRevision(user.getOrg());
            revision.getConfigContent().setBinary(true);
            ConfigurationFactory.commit(revision);

            setRequestPathInfo("/configuration/file/FileDownload");
            addRequestParameter("cfid", revision.getConfigFile().getId().toString());
            addRequestParameter("crid", revision.getId().toString());
            actionPerform();
            assertNotNull(request.getParameter("cfid"));
            String contentType = response.getContentType();
            assertTrue(contentType.startsWith("application/octet-stream"));
        }
}
