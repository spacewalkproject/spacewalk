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
package com.redhat.rhn.domain.action.test;

import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.PackageActionFormatter;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionDetails;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.Set;

/**
 * Tests for PackageActionFormatter.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class PackageActionFormatterTest extends BaseTestCaseWithUser {

    /**
     * Tests getRelatedObjectDescription().
     * @throws Exception if something bad happens
     */
    @SuppressWarnings("unchecked")
    public void testGetRelatedObjectDescription() throws Exception {
        PackageAction action = (PackageAction) ActionFactoryTest.createAction(user,
            ActionFactory.TYPE_PACKAGES_UPDATE);
        PackageActionFormatter formatter = new PackageActionFormatter(action);

        PackageActionDetails details = ((Set<PackageActionDetails>) action.getDetails())
            .iterator().next();
        String expected = "<a href=\"/rhn/software/packages/Details.do?pid=" +
            details.getPackageId().toString() + "\">" + details.getPackageName().getName() +
            "</a>";
        String result = formatter.getRelatedObjectDescription();

        assertEquals(expected, result);
    }
}
