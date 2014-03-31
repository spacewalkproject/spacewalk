/**
 * Copyright (c) 2014 SUSE
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
package com.redhat.rhn.domain.action.config.test;

import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.config.ConfigActionFormatter;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import org.apache.commons.lang.StringEscapeUtils;

/**
 * Tests for ConfigActionFormatter.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ConfigActionFormatterTest extends BaseTestCaseWithUser {

    /**
     * Tests getRelatedObjectDescription().
     * @throws Exception if something bad happens
     */
    public void testGetRelatedObjectDescription() throws Exception {
        ConfigAction action = (ConfigAction) ActionFactoryTest.createAction(user,
            ActionFactory.TYPE_CONFIGFILES_DEPLOY);
        ConfigActionFormatter formatter = new ConfigActionFormatter(action);

        ConfigRevision revision = action.getConfigRevisionActions().iterator().next()
            .getConfigRevision();
        String expected = "<a href=\"/rhn/configuration/file/FileDetails.do?cfid=" +
            revision.getId().toString() +
            "\">" +
            StringEscapeUtils.escapeHtml(revision.getConfigFile().getConfigFileName()
                .getPath()) + "</a>";
        String result = formatter.getRelatedObjectDescription();

        assertTrue(result.contains(expected));
    }
}
